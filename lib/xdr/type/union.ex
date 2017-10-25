defmodule XDR.Type.Union do
  require OK
  import OK, only: ["~>>": 2]
  import XDR.Util, only: ["is_xdr_type_module": 1]
  alias XDR.Type.{
    Int,
    Uint,
    Enum,
    Bool,
    Void,
  }

  # @typedoc """
  # The spec that defines a valid Union XDR type
  # """
  @type t :: discriminant | {discriminant, val :: discriminant}
  @type spec :: [
    {:switch,     switch},
    {:cases,      cases},
    {:default,    switch},
    {:attributes, attributes}
  ]
  @type xdr :: <<_ :: 32>>
  @type discriminant  :: Int.t | Uint.t | Enum.t | Bool.t
  @type switch        :: Int | Uint | Enum | Bool | module
  @type cases         :: [{discriminant, val :: switch | Void | atom}]
  @type attributes    :: [{atom, switch}]

  defmacro __using__(spec: spec) do
    quote do
      @behaviour XDR.Type.Base

      def length, do: 32
      def new, do: unquote(__MODULE__).new(unquote(spec))
      def new(val), do: unquote(__MODULE__).new(val, unquote(spec))
      def valid?(val), do: unquote(__MODULE__).valid?(val, unquote(spec))
      def encode(val), do: unquote(__MODULE__).encode(val, unquote(spec))
      def decode(val), do: unquote(__MODULE__).decode(val, unquote(spec))

      defoverridable [new: 1, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc false
  @spec new(spec :: spec) :: {:ok, native :: t} | {:error, reason :: :invalid}
  def new(spec) do
    default_module = get_default(spec)
    has_default = not is_nil(default_module)

    if has_default, do: default_module.new, else: {:error, :invalid}
  end
  @spec new(native :: t, spec :: spec) :: {:ok, native :: t} | {:error, reason :: :invalid}
  def new({discriminant, val}, spec) do
    if valid?({discriminant, val}, spec), do: {:ok, {discriminant, val}}, else: {:error, :invalid}
  end
  def new(discriminant, spec) do
    if valid?(discriminant, spec), do: {:ok, discriminant}, else: {:error, :invalid}
  end

  @doc """
  Determines if the discriminant (and if provided, the optional val) can be encoded into a valid union
  """
  @spec valid?({discriminant, any} | discriminant, spec :: spec) :: boolean
  def valid?({discriminant, val}, spec) do
    switch_module = get_switch(spec)
    arm_module = get_arm_module(discriminant, spec)

    is_xdr_type_module(arm_module)
    and switch_module.valid?(discriminant)
    and arm_module.valid?(val)
  end
  def valid?(discriminant, spec) do
    switch_module = get_switch(spec)
    default_module = get_default(spec)
    case_module = get_case(discriminant, spec)

    case_exists = not is_nil(case_module)
    has_default = not is_nil(default_module)
    is_case_module = is_xdr_type_module(case_module)

    switch_module.valid?(discriminant) and if case_exists, do: is_case_module, else: has_default
  end

  @doc """
  Encodes a discriminant or {discriminant, value} tuple into an XDR binary
  """
  @spec encode(native :: t, spec :: spec) :: {:ok, xdr :: xdr} | {:error, reason :: :invalid}
  def encode({discriminant, val}, spec) do
    switch_module = get_switch(spec)
    attribute_module = get_attribute(discriminant, spec)

    unless valid?({discriminant, val}, spec) do
      {:error, :invalid}
    else
      OK.with do
        switch <- switch_module.encode(discriminant)
        arm <- attribute_module.encode(val)

        {:ok, switch <> arm}
      end
    end
  end
  def encode(discriminant, spec) do
    switch_module = get_switch(spec)
    default_module = get_default(spec)
    case_module_or_attribute = get_case(discriminant, spec)

    is_case_module = is_xdr_type_module(case_module_or_attribute)
    has_default = not is_nil(default_module)

    case_module = cond do
      is_case_module -> case_module_or_attribute
      has_default -> default_module
      true -> nil
    end

    unless valid?(discriminant, spec) and not is_nil(case_module) do
      {:error, :invalid}
    else
      OK.with do
        switch <- switch_module.encode(discriminant)
        arm <- case_module.new()
          ~>> case_module.encode()

        {:ok, switch <> arm}
      end
    end
  end

  @doc """
  Decodes an XDR binary into a discriminant or {discriminant, value} tuple
  """
  @spec decode(xdr :: xdr, spec :: spec) :: {:ok, native :: t} | {:error, reason :: :invalid}
  def decode(<<discriminant_xdr :: binary-size(4), arm_xdr :: binary>>, spec) do
    switch_module = get_switch(spec)

    OK.with do
      discriminant <- switch_module.decode(discriminant_xdr)
      arm <- decode_arm(discriminant, arm_xdr, spec)

      if is_nil(arm) and byte_size(arm_xdr) === 0 do
        {:ok, discriminant}
      else
        {:ok, {discriminant, arm}}
      end
    end
  end

  #---------------------------------------------------------------------------#
  # ENCODING/DECODING HELPERS
  #---------------------------------------------------------------------------#

  # Decodes the arm after decoding a valid switch
  defp decode_arm(discriminant, arm_xdr, spec) do
    arm_module = get_arm_module(discriminant, spec)

    case arm_module do
      nil -> {:error, :invalid}
      _ -> arm_module.decode(arm_xdr)
    end
  end

  #---------------------------------------------------------------------------#
  # SPEC HELPERS
  #---------------------------------------------------------------------------#

  # Retrieves the module that produces valid discriminant values
  # Must be an Int, Uint, Bool, Enum, or Typedef type that evaluates to one of those modules
  defp get_switch(spec), do: Keyword.get(spec, :switch)

  # Retrieves the Keyword list of discriminant values and their associated modules
  defp get_cases(spec), do: Keyword.get(spec, :cases, [])

  # Retrieves the module responsible for creating a default value
  defp get_default(spec), do: Keyword.get(spec, :default)

  # Retrieves the list of attribute
  defp get_attributes(spec), do: Keyword.get(spec, :attributes, [])

  # Retrieves the case module based on the discriminant, or nil
  defp get_case(discriminant, spec) when is_atom(discriminant) do
    get_cases(spec)
      |> Keyword.get(discriminant)
  end
  defp get_case(discriminant, spec) do
    get_cases(spec)
      |> Elixir.Enum.find({nil, nil}, fn {case, _} -> case === discriminant end)
      |> elem(1)
  end

  # Retrieves the attribute module for a givem discriminant, or nil
  defp get_attribute(discriminant, spec) do
    attr = get_case(discriminant, spec)
    get_attributes(spec)
      |> Keyword.get(attr)
  end

  # Retrieves a module for a given discriminant (attribute, case or default), or nil
  defp get_arm_module(discriminant, spec) do
    get_attribute(discriminant, spec)
    || get_case(discriminant, spec)
    || get_default(spec)
  end
end
