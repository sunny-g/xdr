defmodule XDR.Type.Enum do
  require OK
  import XDR.Util.Macros
  alias XDR.Type.Int

  @typedoc """
  A map or struct defining the spec for an Enum, where values are 4-byte integers
  """
  @type t :: atom
  @type spec :: [{t, Int.t}]
  @type xdr :: <<_ :: 32>>
  @type decode_error :: {:error, :invalid_xdr | :invalid_enum}
  @type encode_error :: {:error, :invalid | :invalid_name | :invalid_enum}

  defmacro __using__(spec: spec) do
    # TODO: update this to statically compile spec into pattern-matched methods
    if not Keyword.keyword?(spec) do
      raise "Enum spec must be a keyword list"
    end

    if Enum.any?(spec, fn {_, v} -> not is_number(v) end) do
      raise "all Enum values must be numbers"
    end

    quote do
      @behaviour XDR.Type.Base

      defdelegate length, to: unquote(__MODULE__)
      def new(name), do: unquote(__MODULE__).new(name, unquote(spec))
      def valid?(name), do: unquote(__MODULE__).valid?(name, unquote(spec))
      def encode(name), do: unquote(__MODULE__).encode(name, unquote(spec))
      def decode(name), do: unquote(__MODULE__).decode(name, unquote(spec))
    end
  end

  @doc false
  def length, do: Int.length

  @doc false
  @spec new(name :: t, enum :: spec) :: {:ok, val :: t} | {:error, reason :: :invalid}
  def new(name, enum) do
    if valid?(name, enum), do: {:ok, name}, else: {:error, :invalid}
  end

  @doc """
  Determines if an atom name is valid according to the enum spec
  """
  @spec valid?(name :: t, enum :: spec) :: boolean
  def valid?(name, _) when not is_atom(name), do: false
  def valid?(_, enum) when not is_list(enum), do: false
  def valid?(name, enum), do: Keyword.has_key?(enum, name) and Keyword.get(enum, name) |> Int.valid?

  @doc """
  Encodes an atom name and enum spec into the name's enum spec 4-byte binary
  """
  @spec encode(name :: t, enum :: spec) :: {:ok, xdr :: xdr} | encode_error
  def encode(name, _) when not is_atom(name), do: {:error, :invalid_name}
  def encode(_, enum) when not is_list(enum), do: {:error, :invalid_enum}
  def encode(name, enum) do
    unless valid?(name, enum) do
      {:error, :invalid}
    else
      Keyword.get(enum, name) |> Int.encode
    end
  end

  @doc """
  Decodes a 4-byte binary and enum spec into the binary's enum spec name
  """
  @spec decode(xdr :: xdr, enum :: spec) :: {:ok, name :: t} | decode_error
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid_xdr}
  def decode(_, enum) when not is_list(enum), do: {:error, :invalid_enum}
  def decode(xdr, enum) do
    OK.with do
      {val, rest} <- Int.decode(xdr)
      case Enum.find(enum, &Kernel.===(elem(&1, 1), val)) do
        {k, _} -> {:ok, {k, rest}}
        nil -> {:error, :invalid_enum}
      end
    end
  end
end
