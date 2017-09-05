defmodule XDR.Type.DoubleFloat.Validation do
  require Math

  defmacro is_valid?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.DoubleFloat do
  require XDR.Type.DoubleFloat.Validation

  @typedoc """
  Single-precision float between ...
  """
  @type t :: number

  @doc """
  Determines if a value is a valid 8-byte float or integer
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(float), do: XDR.Type.DoubleFloat.Validation.is_valid?(float)

  @doc """
  Encodes a double-precision float or integer into an 8-byte binary
  """
  @spec encode(float :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 64>>} | {:error, :invalid}
  def encode(float) when not XDR.Type.DoubleFloat.Validation.is_valid?(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float :: big-signed-float-size(64)>>}

  @doc """
  Decodes an 8-byte binary into an double-precision float
  """
  @spec decode(xdr :: <<_ :: 64>>) :: {:ok, float :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 64, do: {:error, :out_of_bounds}
  def decode(<<float :: big-signed-float-size(64)>>), do: {:ok, float}
  def decode(_), do: {:error, :invalid}
end
