defmodule XDR.Type.HyperInt do
  @moduledoc """
  RFC 4506, Section 4.5 - Hyper Integer
  """

  require Math
  alias XDR.Type.Base
  import XDR.Util.Guards

  @behaviour XDR.Type.Base

  @typedoc """
  Hyper integer between -2^63 to 2^63 - 1
  """
  @type t :: -9_223_372_036_854_775_808..9_223_372_036_854_775_807
  @type xdr :: <<_::_*64>>

  @min_hyper_int -Math.pow(2, 63)
  @max_hyper_int Math.pow(2, 63) - 1
  @length 8

  defguard is_hyper_int(int)
           when is_integer(int) and int >= @min_hyper_int and int <= @max_hyper_int

  @doc false
  def length, do: @length

  @doc false
  @spec new(hyper_int :: t) :: {:ok, hyper_int :: t} | {:error, :invalid}
  def new(hyper_int \\ 0)
  def new(hyper_int) when is_hyper_int(hyper_int), do: {:ok, hyper_int}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte hyper integer
  """
  @spec valid?(hyper_int :: t) :: boolean
  def valid?(hyper_int), do: is_hyper_int(hyper_int)

  @doc """
  Encodes a hyper integer into an 8-byte binary
  """
  @spec encode(hyper_int :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_int) when not is_integer(hyper_int), do: {:error, :invalid}
  def encode(hyper_int) when not is_hyper_int(hyper_int), do: {:error, :out_of_bounds}
  def encode(hyper_int), do: {:ok, <<hyper_int::big-signed-integer-size(64)>>}

  @doc """
  Decodes an 8-byte binary into a hyper integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {hyper_int :: t, rest :: Base.xdr()}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr(xdr), do: {:error, :invalid}

  def decode(<<hyper_int::big-signed-integer-size(64), rest::binary>>),
    do: {:ok, {hyper_int, rest}}

  def decode(_), do: {:error, :invalid}
end
