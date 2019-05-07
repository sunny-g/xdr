defmodule XDR.Type.Int do
  @moduledoc """
  RFC 4506, Section 4.1 - Integer
  """

  alias XDR.Type.Base
  import XDR.Util.Guards

  @behaviour XDR.Type.Base

  @typedoc """
  Integer between -2^31 to 2^31 - 1
  """
  @type t :: -2_147_483_648..2_147_483_647
  @type xdr :: Base.xdr()

  @min_int -2_147_483_648
  @max_int 2_147_483_647
  @length 4

  defguard is_int(int)
           when is_integer(int) and int >= @min_int and int <= @max_int

  @doc false
  def length, do: @length

  @doc false
  @spec new(int :: t) :: {:ok, int :: t} | {:error, :invalid}
  def new(int \\ 0)
  def new(int) when is_int(int), do: {:ok, int}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 4-byte integer
  """
  @spec valid?(int :: t) :: boolean
  def valid?(int), do: is_int(int)

  @doc """
  Encodes an integer into a 4-byte binary
  """
  @spec encode(int :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(int) when not is_integer(int), do: {:error, :invalid}
  def encode(int) when not is_int(int), do: {:error, :out_of_bounds}
  def encode(int), do: {:ok, <<int::big-signed-integer-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {int :: t, rest :: Base.xdr()}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(<<int::big-signed-integer-size(32), rest::binary>>), do: {:ok, {int, rest}}
  def decode(_), do: {:error, :invalid}
end
