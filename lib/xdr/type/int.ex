defmodule XDR.Type.Int.Validation do
  require Math

  @min_int -Math.pow(2, 31)
  @max_int Math.pow(2, 31) - 1

  defmacro is_valid?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_int)
      and unquote(int) <= unquote(@max_int)
    end
  end
end

defmodule XDR.Type.Int do
  require XDR.Type.Int.Validation

  @typedoc """
  Integer between -2^31 to 2^31 - 1
  """
  @type t :: -2147483648..2147483647

  @doc """
  Determines if a value is a valid 4-byte integer
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(int), do: XDR.Type.Int.Validation.is_valid?(int)

  @doc """
  Encodes an integer into a 4-byte binary
  """
  @spec encode(__MODULE__.t) :: {:ok, <<_ :: 32>>} | {:error, :invalid | :out_of_bounds}
  def encode(int) when not is_integer(int), do: {:error, :invalid}
  def encode(int) when not XDR.Type.Int.Validation.is_valid?(int), do: {:error, :out_of_bounds}
  def encode(int), do: {:ok, <<int :: signed-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an integer
  """
  @spec decode(<<_ :: 32>>) :: {:ok, __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 32, do: {:error, :out_of_bounds}
  def decode(<<int :: signed-size(32)>>) when not is_integer(int), do: {:error, :invalid}
  def decode(<<int :: signed-size(32)>>), do: {:ok, int}
  def decode(_), do: {:error, :invalid}
end
