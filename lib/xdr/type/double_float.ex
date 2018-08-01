defmodule XDR.Type.DoubleFloat do
  @moduledoc """
  RFC 4506, Section 4.7 - Double-precision Floating Point
  """

  alias XDR.Type.Base
  import XDR.Util.Macros

  @behaviour XDR.Type.Base

  @typedoc """
  Double-precision float
  """
  @type t :: number
  @type xdr :: <<_::_*64>>

  @length 8

  defguard is_xdr_double(double) when is_float(double) or is_integer(double)

  @doc false
  def length, do: @length

  @doc false
  def new(float \\ 0.0)
  def new(float) when is_xdr_double(float), do: {:ok, float}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte float or integer
  """
  @spec valid?(float :: t) :: boolean
  def valid?(float), do: is_xdr_double(float)

  @doc """
  Encodes a double-precision float or integer into an 8-byte binary
  """
  @spec encode(float :: t) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(float) when not is_xdr_double(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float::big-signed-float-size(64)>>}

  @doc """
  Decodes an 8-byte binary into an double-precision float
  """
  @spec decode(xdr :: xdr) ::
          {:ok, {float :: t, rest :: Base.xdr()}} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(<<float::big-signed-float-size(64), rest::binary>>), do: {:ok, {float, rest}}
  def decode(_), do: {:error, :invalid}
end
