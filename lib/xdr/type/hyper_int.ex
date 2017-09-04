defmodule XDR.Type.HyperInt.Validation do
  require Math

  @min_hyper_int -Math.pow(2, 63)
  @max_hyper_int Math.pow(2, 63) - 1

  defmacro is_valid?(hyper_int) do
    quote do
      is_integer(unquote(hyper_int))
      and unquote(hyper_int) >= unquote(@min_hyper_int)
      and unquote(hyper_int) <= unquote(@max_hyper_int)
    end
  end
end

defmodule XDR.Type.HyperInt do
  require XDR.Type.HyperInt.Validation

  @typedoc """
  Hyper integer between -2^63 to 2^63 - 1
  """
  @type t :: -9223372036854775808..9223372036854775807

  @doc """
  Determines if a value is a valid 8-byte hyper integer
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(hyper_int), do: XDR.Type.HyperInt.Validation.is_valid?(hyper_int)

  @doc """
  Encodes a hyper integer into an 8-byte binary
  """
  @spec encode(hyper_int :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 64>>} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_int) when not is_integer(hyper_int), do: {:error, :invalid}
  def encode(hyper_int) when not XDR.Type.HyperInt.Validation.is_valid?(hyper_int), do: {:error, :out_of_bounds}
  def encode(hyper_int), do: {:ok, <<hyper_int :: signed-size(64)>>}

  @doc """
  Decodes an 8-byte binary into a hyper integer
  """
  @spec decode(xdr :: <<_ :: 64>>) :: {:ok, hyper_int :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 64, do: {:error, :out_of_bounds}
  def decode(<<hyper_int :: signed-size(64)>>) when not is_integer(hyper_int), do: {:error, :invalid}
  def decode(<<hyper_int :: signed-size(64)>>), do: {:ok, hyper_int}
  def decode(_), do: {:error, :invalid}
end
