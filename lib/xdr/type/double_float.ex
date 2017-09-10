defmodule XDR.Type.DoubleFloat.Validation do
  defmacro is_valid_double_float?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.DoubleFloat do
  import XDR.Util.Macros
  import XDR.Type.DoubleFloat.Validation

  @typedoc """
  Single-precision float between ...
  """
  @type t :: number
  @type xdr :: <<_ :: 64>>

  @size 64

  @doc """
  Determines if a value is a valid 8-byte float or integer
  """
  @spec is_valid?(any) :: boolean
  def is_valid?(float), do: is_valid_double_float?(float)

  @doc """
  Encodes a double-precision float or integer into an 8-byte binary
  """
  @spec encode(float :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(float) when not is_valid_double_float?(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float :: big-signed-float-size(@size)>>}

  @doc """
  Decodes an 8-byte binary into an double-precision float
  """
  @spec decode(xdr :: __MODULE__.xdr) :: {:ok, float :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when bit_size(xdr) > @size, do: {:error, :out_of_bounds}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<float :: big-signed-float-size(@size)>>), do: {:ok, float}
  def decode(_), do: {:error, :invalid}
end
