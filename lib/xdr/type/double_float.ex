defmodule XDR.Type.DoubleFloat.Validation do
  defmacro is_valid_double_float?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.DoubleFloat do
  @behaviour XDR.Type.Base

  import XDR.Util.Macros
  import XDR.Type.DoubleFloat.Validation

  @typedoc """
  Single-precision float between ...
  """
  @type t :: number
  @type xdr :: <<_ :: 64>>

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
  @spec valid?(any) :: boolean
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
  @spec decode(xdr :: xdr) :: {:ok, float :: t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @length, do: {:error, :out_of_bounds}
  def decode(<<float :: big-signed-float-size(@length)>>), do: {:ok, float}
  def decode(_), do: {:error, :invalid}
end
