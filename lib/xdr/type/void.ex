defmodule XDR.Type.Void do
  @behaviour XDR.Type.Base

  @typedoc """
  Void type
  """
  @type t :: nil

  @doc false
  def length, do: 0

  def new(val \\ nil)
  def new(nil), do: {:ok, nil}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if value is nil or not
  """
  @spec valid?(t) :: boolean
  def valid?(nil), do: true
  def valid?(_), do: false

  @doc """
  Encodes nil to an empty binary
  """
  @spec encode(t) :: {:ok, <<>>} | {:error, :invalid}
  def encode(nil), do: {:ok, <<>>}
  def encode(_), do: {:error, :invalid}

  @doc """
  Decodes an empty binary to nil
  """
  @spec decode(xdr :: <<>>) :: {:ok, {native :: t, rest :: <<_ :: 32>>}} | {:error, :invalid}
  def decode(<<rest :: binary>>), do: {:ok, {nil, rest}}
  def decode(_), do: {:error, :invalid}
end
