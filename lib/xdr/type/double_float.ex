defmodule XDR.Type.DoubleFloat.Validation do
  @moduledoc false

  defmacro is_valid_double_float?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.DoubleFloat do
  @moduledoc """
  RFC 4506, Section 4.7 - Double-precision Floating Point
  """

  alias XDR.Type.Base
  import XDR.Util.Macros
  import XDR.Type.DoubleFloat.Validation

  @behaviour XDR.Type.Base

  @typedoc """
  Double-precision float
  """
  @type t :: number
  @type xdr :: <<_ :: _*64>>

  @length 64

  @doc false
  def length, do: @length

  @doc false
  def new(float \\ 0.0)
  def new(float) when is_valid_double_float?(float), do: {:ok, float}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte float or integer
  """
  @spec valid?(float :: t) :: boolean
  def valid?(float), do: is_valid_double_float?(float)

  @doc """
  Encodes a double-precision float or integer into an 8-byte binary
  """
  @spec encode(float :: t) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(float) when not is_valid_double_float?(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float :: big-signed-float-size(@length)>>}

  @doc """
  Decodes an 8-byte binary into an double-precision float
  """
  @spec decode(xdr :: xdr) :: {:ok, {float :: t, rest :: Base.xdr}} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<float :: big-signed-float-size(@length), rest :: binary>>), do: {:ok, {float, rest}}
  def decode(_), do: {:error, :invalid}
end
