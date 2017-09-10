defmodule XDR.Type.Enum do
  import XDR.Util.Macros
  alias XDR.Type.Int

  @typedoc """
  A map or struct defining the spec for an Enum, where values are 4-byte integers
  """
  @type t :: struct | %{
    optional(name :: __MODULE__.name) => enum :: Int.t
  }
  @type name :: atom
  @type xdr :: <<_ :: 32>>
  @type decode_error :: {:error, :invalid_xdr | :invalid_enum}
  @type encode_error :: {:error, :invalid | :invalid_name | :invalid_enum}

  @doc false
  def length, do: Int.length

  @doc """
  Determines if an atom name is a valid according to the enum spec
  """
  @spec is_valid?(any, enum :: __MODULE__.t) :: boolean
  def is_valid?(name, enum), do: Map.has_key?(enum, name) and Map.get(enum, name) |> Int.is_valid?

  @doc """
  Encodes an atom name and enum spec into the name's enum spec 4-byte binary
  """
  @spec encode(name :: __MODULE__.name, enum :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | __MODULE__.encode_error
  def encode(name, _) when not is_atom(name), do: {:error, :invalid_name}
  def encode(_, enum) when not is_map(enum), do: {:error, :invalid_enum}
  def encode(name, enum) do
    case is_valid?(name, enum) do
      true -> Map.get(enum, name) |> Int.encode
      false -> {:error, :invalid}
    end
  end

  @doc """
  Decodes a 4-byte binary and enum spec into the binary's enum spec name
  """
  @spec decode(xdr :: __MODULE__.xdr, enum :: __MODULE__.t) :: {:ok, name :: __MODULE__.name} | __MODULE__.decode_error
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid_xdr}
  def decode(_, enum) when not is_map(enum), do: {:error, :invalid_enum}
  def decode(xdr, enum) do
    val = Int.decode(xdr) |> elem(1)
    case Enum.find(enum, fn {_, v} -> match?(^v, val) end) do
      {k, _} -> {:ok, k}
      nil -> {:error, :invalid_enum}
    end
  end
end
