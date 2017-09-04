defmodule XDR.Type.Int.Validation do
  require Math

  @min_int -Math.pow(2, 31)
  @max_int Math.pow(2, 31) - 1

  defmacro is_valid?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_int)
      and unquote(int) <= unquote(@max_int)
    end
  end
end

defmodule XDR.Type.Int do
  import XDR.Type.Int.Validation

  def encode(int) when not is_integer(int), do: {:error, :invalid}
  def encode(int) when not is_valid?(int), do: {:error, :out_of_bounds}
  def encode(int), do: {:ok, <<int :: signed-size(32)>>}

  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 32, do: {:error, :out_of_bounds}
  def decode(<<int :: signed-size(32)>>) when not is_integer(int), do: {:error, :invalid}
  def decode(<<int :: signed-size(32)>>), do: {:ok, int}
  def decode(_), do: {:error, :invalid}
end
