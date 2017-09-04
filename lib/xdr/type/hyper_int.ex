defmodule XDR.Type.HyperInt.Validation do
  require Math

  @min_int -Math.pow(2, 63)
  @max_int Math.pow(2, 63) - 1

  defmacro is_valid?(hyper_int) do
    quote do
      is_integer(unquote(hyper_int))
      and unquote(hyper_int) >= unquote(@min_int)
      and unquote(hyper_int) <= unquote(@max_int)
    end
  end
end

defmodule XDR.Type.HyperInt do
  import XDR.Type.HyperInt.Validation

  def encode(hyper_int) when not is_integer(hyper_int), do: {:error, :invalid}
  def encode(hyper_int) when not is_valid?(hyper_int), do: {:error, :out_of_bounds}
  def encode(hyper_int), do: {:ok, <<hyper_int :: signed-size(64)>>}

  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 64, do: {:error, :out_of_bounds}
  def decode(<<hyper_int :: signed-size(64)>>) when not is_integer(hyper_int), do: {:error, :invalid}
  def decode(<<hyper_int :: signed-size(64)>>), do: {:ok, hyper_int}
  def decode(_), do: {:error, :invalid}
end
