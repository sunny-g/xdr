defmodule XDR.Type.Union do
  @moduledoc """
  RFC 4506, Section 4.15 - Discriminated Union
  """

  import XDR.Util

  alias XDR.Type.{
    Base,
    Int,
    Uint,
    Enum,
    Bool,
    Void
  }

  @type t :: discriminant | {discriminant, val :: discriminant}
  @type spec :: [
          {:switch, switch},
          {:cases, cases},
          {:default, switch},
          {:attributes, attributes}
        ]
  @type xdr :: Base.xdr()
  @type discriminant :: Int.t() | Uint.t() | Enum.t() | Bool.t()
  @type switch :: Int | Uint | Enum | Bool | module
  @type cases :: [{discriminant, val :: switch | Void | atom}]
  @type attributes :: [{atom, switch}]

  defmacro __using__(spec) do
    switch_module = get_switch(spec)
    required = quote do: require(unquote(switch_module))

    quote do
      unquote(required)

      @behaviour XDR.Type.Base

      def length, do: :union
      def new, do: unquote(__MODULE__).new(unquote(spec))
      def new(val), do: unquote(__MODULE__).new(val, unquote(spec))
      def valid?(val), do: unquote(__MODULE__).valid?(val, unquote(spec))
      def encode(val), do: unquote(__MODULE__).encode(val, unquote(spec))
      def decode(val), do: unquote(__MODULE__).decode(val, unquote(spec))

      defoverridable length: 0, new: 0, new: 1, valid?: 1, encode: 1, decode: 1
    end
  end

  @doc false
  @spec new(spec :: spec) :: {:ok, discriminant :: t} | {:error, reason :: :invalid}
  def new(spec) do
    default_module = get_default(spec)
    has_default = not is_nil(default_module)

    if has_default, do: default_module.new, else: {:error, :invalid}
  end

  @spec new(discriminant :: t, spec :: spec) ::
          {:ok, discriminant :: t} | {:error, reason :: :invalid}
  def new({discriminant, val}, spec) do
    if valid?({discriminant, val}, spec), do: {:ok, {discriminant, val}}, else: {:error, :invalid}
  end

  def new(discriminant, spec) do
    if valid?(discriminant, spec), do: {:ok, discriminant}, else: {:error, :invalid}
  end

  @doc """
  Determines if the discriminant (and if provided, the optional val) can be encoded into a valid union
  """
  @spec valid?(discriminant :: t, spec :: spec) :: boolean
  def valid?({discriminant, val}, spec) do
    switch_module = get_switch(spec)
    arm_module = get_arm_module(discriminant, spec)

    valid_xdr_type?(arm_module) and switch_module.valid?(discriminant) and arm_module.valid?(val)
  end

  def valid?(discriminant, spec) do
    switch_module = get_switch(spec)
    default_module = get_default(spec)
    case_module = get_case(discriminant, spec)

    case_exists = not is_nil(case_module)
    has_default = not is_nil(default_module)
    is_case_module = valid_xdr_type?(case_module)

    switch_module.valid?(discriminant) and if case_exists, do: is_case_module, else: has_default
  end

  @doc """
  Encodes a discriminant or {discriminant, value} tuple into an XDR binary
  """
  @spec encode(discriminant :: t, spec :: spec) ::
          {:ok, xdr :: xdr} | {:error, reason :: :invalid}
  def encode({discriminant, val}, spec) do
    switch_module = get_switch(spec)
    attribute_module = get_attribute(discriminant, spec)

    if valid?({discriminant, val}, spec) do
      with {:ok, switch} <- switch_module.encode(discriminant),
           {:ok, arm} <- attribute_module.encode(val) do
        {:ok, switch <> arm}
      end
    else
      {:error, :invalid}
    end
  end

  def encode(discriminant, spec) do
    switch_module = get_switch(spec)
    default_module = get_default(spec)
    case_module_or_attribute = get_case(discriminant, spec)

    is_case_module = valid_xdr_type?(case_module_or_attribute)
    has_default = not is_nil(default_module)

    case_module =
      cond do
        is_case_module -> case_module_or_attribute
        has_default -> default_module
        true -> nil
      end

    if valid?(discriminant, spec) and not is_nil(case_module) do
      with {:ok, switch} <- switch_module.encode(discriminant),
           {:ok, val} <- case_module.new(),
           {:ok, arm} <- case_module.encode(val) do
        {:ok, switch <> arm}
      end
    else
      {:error, :invalid}
    end
  end

  @doc """
  Decodes an XDR binary into a discriminant or {discriminant, value} tuple
  """
  @spec decode(xdr :: xdr, spec :: spec) ::
          {:ok, {discriminant :: t, rest :: Base.xdr()}} | {:error, reason :: :invalid}
  def decode(<<discriminant_xdr::binary-size(4), arm_xdr::binary>>, spec) do
    switch_module = get_switch(spec)

    with {:ok, {discriminant, _}} <- switch_module.decode(discriminant_xdr),
         {:ok, {arm, rest}} <- decode_arm(discriminant, arm_xdr, spec) do
      if is_nil(arm) and arm_xdr === rest do
        {:ok, {discriminant, rest}}
      else
        {:ok, {{discriminant, arm}, rest}}
      end
    end
  end

  # ---------------------------------------------------------------------------#
  # ENCODING/DECODING HELPERS
  # ---------------------------------------------------------------------------#

  # Decodes the arm after decoding a valid switch
  defp decode_arm(discriminant, arm_xdr, spec) do
    arm_module = get_arm_module(discriminant, spec)

    case arm_module do
      nil -> {:error, :invalid}
      _ -> arm_module.decode(arm_xdr)
    end
  end

  # ---------------------------------------------------------------------------#
  # SPEC HELPERS
  # ---------------------------------------------------------------------------#

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
    spec
    |> get_cases()
    |> Keyword.get(discriminant)
  end

  defp get_case(discriminant, spec) do
    spec
    |> get_cases()
    |> Elixir.Enum.find({nil, nil}, &Kernel.===(elem(&1, 0), discriminant))
    |> elem(1)
  end

  # Retrieves the attribute module for a givem discriminant, or nil
  defp get_attribute(discriminant, spec) do
    attr = get_case(discriminant, spec)

    spec
    |> get_attributes()
    |> Keyword.get(attr)
  end

  # Retrieves a module for a given discriminant (attribute, case or default), or nil
  defp get_arm_module(discriminant, spec) do
    get_attribute(discriminant, spec) || get_case(discriminant, spec) || get_default(spec)
  end
end
