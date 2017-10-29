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
  import XDR.Util.Macros
  import XDR.Type.Uint.Validation

  @behaviour XDR.Type.Base

  @typedoc """
  Integer between 0 and 2^32 - 1
  """
  @type t :: 0..4294967295
  @type xdr :: <<_ :: 32>>

  @length 32

  @doc false
  def length, do: @length

  @doc false
  def new(uint \\ 0)
  def new(uint) when is_valid_uint?(uint), do: {:ok, uint}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 4-byte unsigned integer
  """
  @spec valid?(t) :: boolean
  def valid?(uint), do: is_valid_uint?(uint)

  @doc """
  Encodes an unsigned integer into a 4-byte binary
  """
  @spec encode(uint :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(uint) when not is_integer(uint), do: {:error, :invalid}
  def encode(uint) when not is_valid_uint?(uint), do: {:error, :out_of_bounds}
  def encode(uint), do: {:ok, <<uint :: big-unsigned-integer-size(@length)>>}

  @doc """
  Decodes a 4-byte binary into an unsigned integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {uint :: t, rest :: xdr}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<uint :: big-unsigned-integer-size(@length), rest :: binary>>), do: {:ok, {uint, rest}}
  def decode(_), do: {:error, :invalid}
end
