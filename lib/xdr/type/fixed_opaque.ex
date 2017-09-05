defmodule XDR.Type.FixedOpaque.Validation do
  defmacro is_valid?(opaque, len) do
    quote do
      is_binary(unquote(opaque)) and byte_size(unquote(opaque)) === unquote(len)
    end
  end
end

defmodule XDR.Type.FixedOpaque do
  require XDR.Type.FixedOpaque.Validation
  alias XDR.Util

  @doc """
  """
  def is_valid?(opaque, len), do: XDR.Type.FixedOpaque.Validation.is_valid?(opaque, len)

  @doc """
  """
  def encode(opaque, len) when not XDR.Type.FixedOpaque.Validation.is_valid?(opaque, len), do: {:error, :invalid}
  def encode(opaque, len) when rem(len, 4) === 0, do: {:ok, opaque}
  def encode(opaque, len) when rem(len, 4) === 3, do: {:ok, opaque <> <<0>>}
  def encode(opaque, len) when rem(len, 4) === 2, do: {:ok, opaque <> <<0, 0>>}
  def encode(opaque, len) when rem(len, 4) === 1, do: {:ok, opaque <> <<0, 0, 0>>}

  @doc """
  """
  def decode(xdr, _) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr, _) when rem(byte_size(xdr), 4) !== 0, do: {:error, :invalid}
  def decode(xdr, len) when len > byte_size(xdr), do: {:error, :out_of_bounds}
  def decode(xdr, len) do
    <<opaque :: binary-size(len), _ :: binary>> = xdr
    {:ok, opaque}
  end
end
