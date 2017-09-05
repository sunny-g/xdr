defmodule XDR.Type.Bool do
  alias XDR.Type.Int

  @typedoc """
  Plain boolean
  """
  @type t :: boolean

  @doc """
  Determines if value is a valid boolean
  """
  @spec is_valid?(bool :: __MODULE__.t) :: boolean
  def is_valid?(false), do: true
  def is_valid?(true), do: true
  def is_valid?(_), do: false

  @doc """
  Encodes a boolean value into 4-byte binary - true maps to 1, false maps to 0
  """
  @spec encode(bool :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 32>>} | {:error, :invalid}
  def encode(false), do: Int.encode(0)
  def encode(true), do: Int.encode(1)
  def encode(_), do: {:error, :invalid}

  @doc """
  Decodes a 4-byte binary into a boolean
  """
  @spec decode(xdr :: <<_ :: 32>>) :: {:ok, bool :: __MODULE__.t} | {:error, :invalid}
  def decode(<<0, 0, 0, 0>>), do: false
  def decode(<<0, 0, 0, 1>>), do: true
  def decode(_), do: {:error, :invalid}
end
