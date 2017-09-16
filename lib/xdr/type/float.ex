defmodule XDR.Type.Float.Validation do
  defmacro is_valid_float?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.Float do
  @behaviour XDR.Type.Base

  import XDR.Util.Macros
  import XDR.Type.Float.Validation

  @typedoc """
  Single-precision float between ...
  """
  @type t :: number
  @type xdr :: <<_ :: 32>>

  @length 32

  @doc false
  def length, do: @length

  @doc """
  Determines if a value is a valid 4-byte float or integer
  """
  @spec valid?(any) :: boolean
  def valid?(float), do: is_valid_float?(float)

  @doc """
  Encodes a single-precision float or integer into a 4-byte binary
  """
  @spec encode(float :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(float) when not is_valid_float?(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float :: big-signed-float-size(@length)>>}

  @doc """
  Decodes a 4-byte binary into an single-precision float
  """
  @spec decode(xdr :: __MODULE__.xdr) :: {:ok, float :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @length, do: {:error, :out_of_bounds}
  def decode(<<float :: big-signed-float-size(@length)>>), do: {:ok, float}
  def decode(_), do: {:error, :invalid}
end
