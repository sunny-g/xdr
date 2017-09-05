defmodule XDR.Type.Void do
  @typedoc """
  Void type
  """
  @type t :: nil

  @doc """
  Determines if value is nil or not
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(nil), do: true
  def is_valid?(_), do: false

  @doc """
  Encodes nil to an empty binary
  """
  @spec encode(__MODULE__.t) :: {:ok, <<>>} | {:error, :invalid}
  def encode(nil), do: {:ok, <<>>}
  def encode(_), do: {:error, :invalid}

  @doc """
  Decodes an empty binary to nil
  """
  @spec decode(xdr :: <<>>) :: {:ok, nil} | {:error, :invalid}
  def decode(<<>>), do: {:ok, nil}
  def decode(_), do: {:error, :invalid}
end
