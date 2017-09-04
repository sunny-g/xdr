defmodule XDR.Type.HyperUint.Validation do
  require Math

  @min_int 0
  @max_int Math.pow(2, 64) - 1

  defmacro is_valid?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_int)
      and unquote(int) <= unquote(@max_int)
    end
  end
end

defmodule XDR.Type.HyperUint do
  import XDR.Type.HyperUint.Validation

  def encode(int) when not is_integer(int), do: {:error, :invalid}
  def encode(int) when not is_valid?(int), do: {:error, :out_of_bounds}
  def encode(int), do: {:ok, <<int :: unsigned-size(64)>>}

  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 64, do: {:error, :out_of_bounds}
  def decode(<<int :: unsigned-size(64)>>) when not is_integer(int), do: {:error, :invalid}
  def decode(<<int :: unsigned-size(64)>>), do: {:ok, int}
  def decode(_), do: {:error, :invalid}
end
