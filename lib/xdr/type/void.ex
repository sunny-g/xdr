defmodule XDR.Type.Void do
  @typedoc """
  Void type
  """
  @type t :: nil

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
  @spec decode(xdr :: <<>>) :: {:ok, nil} | {:error, :invalid}
  def decode(<<>>), do: {:ok, nil}
  def decode(_), do: {:error, :invalid}
end
