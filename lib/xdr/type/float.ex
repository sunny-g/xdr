defmodule XDR.Type.Float.Validation do
  require Math

  defmacro is_valid?(float) do
    quote do
      is_float(unquote(float)) or is_integer(unquote(float))
    end
  end
end

defmodule XDR.Type.Float do
  require XDR.Type.Float.Validation

  @typedoc """
  Single-precision float between ...
  """
  @type t :: number

  @doc """
  Determines if a value is a valid 4-byte float or integer
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(float), do: XDR.Type.Float.Validation.is_valid?(float)

  @doc """
  Encodes a single-precision float or integer into a 4-byte binary
  """
  @spec encode(float :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 32>>} | {:error, :invalid}
  def encode(float) when not XDR.Type.Float.Validation.is_valid?(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float :: big-signed-float-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an single-precision float
  """
  @spec decode(xdr :: <<_ :: 32>>) :: {:ok, float :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 32, do: {:error, :out_of_bounds}
  def decode(<<float :: big-signed-float-size(32)>>), do: {:ok, float}
  def decode(_), do: {:error, :invalid}
end
