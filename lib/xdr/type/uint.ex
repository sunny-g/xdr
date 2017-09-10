defmodule XDR.Type.Uint.Validation do
  require Math

  @min_uint 0
  @max_uint Math.pow(2, 32) - 1

  defmacro is_valid_uint?(uint) do
    quote do
      is_integer(unquote(uint))
      and unquote(uint) >= unquote(@min_uint)
      and unquote(uint) <= unquote(@max_uint)
    end
  end
end

defmodule XDR.Type.Uint do
  import XDR.Type.Uint.Validation
  import XDR.Util.Macros

  @typedoc """
  Integer between 0 and 2^32 - 1
  """
  @type t :: 0..4294967295
  @type xdr :: <<_ :: 32>>

  @size 32

  @doc """
  Determines if a value is a valid 4-byte unsigned integer
  """
  @spec is_valid?(any) :: boolean
  def is_valid?(uint), do: is_valid_uint?(uint)

  @doc """
  Encodes an unsigned integer into a 4-byte binary
  """
  @spec encode(uint :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid | :out_of_bounds}
  def encode(uint) when not is_integer(uint), do: {:error, :invalid}
  def encode(uint) when not is_valid_uint?(uint), do: {:error, :out_of_bounds}
  def encode(uint), do: {:ok, <<uint :: big-unsigned-integer-size(@size)>>}

  @doc """
  Decodes a 4-byte binary into an unsigned integer
  """
  @spec decode(xdr :: __MODULE__.xdr) :: {:ok, uint :: __MODULE__.t} | {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @size, do: {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<uint :: big-unsigned-integer-size(@size)>>), do: {:ok, uint}
  def decode(_), do: {:error, :invalid}
end
