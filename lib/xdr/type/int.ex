defmodule XDR.Type.Int.Validation do
  require Math

  @min_int -Math.pow(2, 31)
  @max_int Math.pow(2, 31) - 1

  defmacro is_valid_int?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_int)
      and unquote(int) <= unquote(@max_int)
    end
  end
end

defmodule XDR.Type.Int do
  @behaviour XDR.Type.Base

  import XDR.Util.Macros
  import XDR.Type.Int.Validation

  @typedoc """
  Integer between -2^31 to 2^31 - 1
  """
  @type t :: -2147483648..2147483647
  @type xdr :: <<_ :: 32>>

  @length 32

  @doc false
  def length, do: @length

  @doc """
  Determines if a value is a valid 4-byte integer
  """
  @spec is_valid?(any) :: boolean
  def is_valid?(int), do: is_valid_int?(int)

  @doc """
  Encodes an integer into a 4-byte binary
  """
  @spec encode(int :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid | :out_of_bounds}
  def encode(int) when not is_integer(int), do: {:error, :invalid}
  def encode(int) when not is_valid_int?(int), do: {:error, :out_of_bounds}
  def encode(int), do: {:ok, <<int :: big-signed-integer-size(@length)>>}

  @doc """
  Decodes a 4-byte binary into an integer
  """
  @spec decode(xdr :: __MODULE__.xdr) :: {:ok, int :: __MODULE__.t} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @length, do: {:error, :invalid}
  def decode(<<int :: big-signed-integer-size(@length)>>), do: {:ok, int}
  def decode(_), do: {:error, :invalid}
end
