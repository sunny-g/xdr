defmodule XDR.Type.Enum do
  import XDR.Util.Macros
  alias XDR.Type.Int

  @typedoc """
  A map or struct defining the spec for an Enum, where values are 4-byte integers
  """
  @type t :: struct | %{
    optional(name :: name) => enum :: Int.t
  }
  @type name :: atom
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

      defoverridable [length: 0, new: 1, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc false
  def length, do: Int.length

  @doc false
  def new(name, enum) do
    case valid?(name, enum) do
      true -> {:ok, name}
      false -> {:error, :invalid}
    end
  end

  @doc """
  Determines if an atom name is valid according to the enum spec
  """
  @spec valid?(any, enum :: t) :: boolean
  def valid?(name, _) when not is_atom(name), do: false
  def valid?(_, enum) when not is_list(enum), do: false
  def valid?(name, enum), do: Keyword.has_key?(enum, name) and Keyword.get(enum, name) |> Int.valid?

  @doc """
  Encodes an atom name and enum spec into the name's enum spec 4-byte binary
  """
  @spec encode(name :: name, enum :: t) :: {:ok, xdr :: xdr} | encode_error
  def encode(name, _) when not is_atom(name), do: {:error, :invalid_name}
  def encode(_, enum) when not is_list(enum), do: {:error, :invalid_enum}
  def encode(name, enum) do
    case valid?(name, enum) do
      true -> Keyword.get(enum, name) |> Int.encode
      false -> {:error, :invalid}
    end
  end

  @doc """
  Decodes a 4-byte binary and enum spec into the binary's enum spec name
  """
  @spec decode(xdr :: xdr, enum :: t) :: {:ok, name :: name} | decode_error
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid_xdr}
  def decode(_, enum) when not is_list(enum), do: {:error, :invalid_enum}
  def decode(xdr, enum) do
    val = Int.decode(xdr) |> elem(1)
    case Enum.find(enum, fn {_, v} -> match?(^v, val) end) do
      {k, _} -> {:ok, k}
      nil -> {:error, :invalid_enum}
    end
  end
end
