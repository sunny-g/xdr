defmodule XDR.Type.Uint.Validation do
  require Math

  @min_uint 0
  @max_uint Math.pow(2, 32) - 1

  defmacro is_valid?(uint) do
    quote do
      is_integer(unquote(uint))
      and unquote(uint) >= unquote(@min_uint)
      and unquote(uint) <= unquote(@max_uint)
    end
  end
end

defmodule XDR.Type.Uint do
  require XDR.Type.Uint.Validation

  @typedoc """
  Integer between 0 and 2^32 - 1
  """
  @type t :: 0..4294967295

  @doc """
  Determines if a value is a valid 4-byte unsigned integer
  """
  @spec is_valid?(__MODULE__.t) :: boolean
  def is_valid?(uint), do: XDR.Type.Uint.Validation.is_valid?(uint)

  @doc """
  Encodes an unsigned integer into a 4-byte binary
  """
  @spec encode(uint :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 32>>} | {:error, :invalid | :out_of_bounds}
  def encode(uint) when not is_integer(uint), do: {:error, :invalid}
  def encode(uint) when not XDR.Type.Uint.Validation.is_valid?(uint), do: {:error, :out_of_bounds}
  def encode(uint), do: {:ok, <<uint :: unsigned-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an unsigned integer
  """
  @spec decode(xdr :: <<_ :: 32>>) :: {:ok, uint :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 32, do: {:error, :out_of_bounds}
  def decode(<<uint :: unsigned-size(32)>>) when not is_integer(uint), do: {:error, :invalid}
  def decode(<<uint :: unsigned-size(32)>>), do: {:ok, uint}
  def decode(_), do: {:error, :invalid}
end
