defmodule XDR.Type.HyperInt.Validation do
  require Math

  @min_hyper_int -Math.pow(2, 63)
  @max_hyper_int Math.pow(2, 63) - 1

  defmacro is_valid_hyper_int?(hyper_int) do
    quote do
      is_integer(unquote(hyper_int))
      and unquote(hyper_int) >= unquote(@min_hyper_int)
      and unquote(hyper_int) <= unquote(@max_hyper_int)
    end
  end
end

defmodule XDR.Type.HyperInt do
  import XDR.Util.Macros
  import XDR.Type.HyperInt.Validation

  @typedoc """
  Hyper integer between -2^63 to 2^63 - 1
  """
  @type t :: -9223372036854775808..9223372036854775807
  @type xdr :: <<_ :: 64>>

  @size 64

  @doc """
  Determines if a value is a valid 8-byte hyper integer
  """
  @spec is_valid?(any) :: boolean
  def is_valid?(hyper_int), do: is_valid_hyper_int?(hyper_int)

  @doc """
  Encodes a hyper integer into an 8-byte binary
  """
  @spec encode(hyper_int :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_int) when not is_integer(hyper_int), do: {:error, :invalid}
  def encode(hyper_int) when not is_valid_hyper_int?(hyper_int), do: {:error, :out_of_bounds}
  def encode(hyper_int), do: {:ok, <<hyper_int :: big-signed-integer-size(@size)>>}

  @doc """
  Decodes an 8-byte binary into a hyper integer
  """
  @spec decode(xdr :: __MODULE__.xdr) :: {:ok, hyper_int :: __MODULE__.t} | {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @size, do: {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<hyper_int :: big-signed-integer-size(@size)>>), do: {:ok, hyper_int}
  def decode(_), do: {:error, :invalid}
end
