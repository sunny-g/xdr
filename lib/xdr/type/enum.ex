defmodule XDR.Type.Enum do
  alias XDR.Type.Int

  @typedoc """
  A map or struct defining the spec for an Enum, where values are 4-byte integers
  """
  @type t :: map | struct

  @doc """
  """
  @spec is_valid?(name :: atom, enum :: __MODULE__.t) :: boolean
  def is_valid?(name, enum), do: Map.has_key?(enum, name) and Map.get(enum, name) |> Int.is_valid?

  @doc """
  Encodes an atom name and enum spec into the name's enum spec 4-byte binary
  """
  @spec encode(name :: atom, enum :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 32>>} | {:error, :invalid}
  def encode(name, enum) do
    case is_valid?(name, enum) do
      true -> Map.get(enum, name) |> Int.encode
      false -> {:error, :invalid}
    end
  end

  @doc """
  Decodes a 4-byte binary and enum spec into the binary's enum spec name
  """
  @spec decode(xdr :: <<_ :: 32>>, enum :: __MODULE__.t) :: {:ok, name :: atom} | {:error, :invalid}
  def decode(xdr, enum) do
    val = Int.decode(xdr) |> elem(1)
    case Enum.find(enum, fn {_, v} -> v === val end) do
      {k, _} -> {:ok, k}
      nil -> {:error, :invalid}
    end
  end
end