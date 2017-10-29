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
  @behaviour XDR.Type.Base

  import XDR.Util.Macros
  import XDR.Type.HyperInt.Validation

  @typedoc """
  Hyper integer between -2^63 to 2^63 - 1
  """
  @type t :: -9223372036854775808..9223372036854775807
  @type xdr :: <<_ :: 64>>

  @length 64

  @doc false
  def length, do: @length

  @doc false
  def new(hyper_int \\ 0)
  def new(hyper_int) when is_valid_hyper_int?(hyper_int), do: {:ok, hyper_int}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte hyper integer
  """
  @spec valid?(t) :: boolean
  def valid?(hyper_int), do: is_valid_hyper_int?(hyper_int)

  @doc """
  Encodes a hyper integer into an 8-byte binary
  """
  @spec encode(hyper_int :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_int) when not is_integer(hyper_int), do: {:error, :invalid}
  def encode(hyper_int) when not is_valid_hyper_int?(hyper_int), do: {:error, :out_of_bounds}
  def encode(hyper_int), do: {:ok, <<hyper_int :: big-signed-integer-size(@length)>>}

  @doc """
  Decodes an 8-byte binary into a hyper integer
  """
  @spec decode(xdr :: xdr) :: {:ok, hyper_int :: t} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<hyper_int :: big-signed-integer-size(@length), rest :: binary>>), do: {:ok, {hyper_int, rest}}
  def decode(_), do: {:error, :invalid}
end
