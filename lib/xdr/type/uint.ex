defmodule XDR.Type.Uint do
  @moduledoc """
  RFC 4506, Section 4.2 - Unsigned Integer
  """

  @behaviour XDR.Type.Base

  require Math
  alias XDR.Type.Base
  import XDR.Util.Macros

  @typedoc """
  Integer between 0 and 2^32 - 1
  """
  @type t :: 0..4_294_967_295
  @type xdr :: Base.xdr()

  @min_uint 0
  @max_uint Math.pow(2, 32) - 1
  @length 4

  defguard is_uint(uint)
           when is_integer(uint) and uint >= @min_uint and uint <= @max_uint

  defmacro __using__(_ \\ []) do
    quote do
      defdelegate length(), to: unquote(__MODULE__)
      defdelegate new(uint \\ 0), to: unquote(__MODULE__)
      defdelegate valid?(uint), to: unquote(__MODULE__)
      defdelegate encode(uint), to: unquote(__MODULE__)
      defdelegate decode(uint), to: unquote(__MODULE__)
    end
  end

  @doc false
  def length, do: @length

  @doc false
  @spec new(uint :: t) :: {:ok, uint :: t} | {:error, :invalid}
  def new(uint \\ 0)
  def new(uint) when is_uint(uint), do: {:ok, uint}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 4-byte unsigned integer
  """
  @spec valid?(uint :: t) :: boolean
  def valid?(uint), do: is_uint(uint)

  @doc """
  Encodes an unsigned integer into a 4-byte binary
  """
  @spec encode(uint :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(uint) when not is_integer(uint), do: {:error, :invalid}
  def encode(uint) when not is_uint(uint), do: {:error, :out_of_bounds}
  def encode(uint), do: {:ok, <<uint::big-unsigned-integer-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an unsigned integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {uint :: t, rest :: Base.xdr()}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(<<uint::big-unsigned-integer-size(32), rest::binary>>), do: {:ok, {uint, rest}}
  def decode(_), do: {:error, :invalid}
end
