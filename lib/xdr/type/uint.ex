defmodule XDR.Type.Uint.Validation do
  @moduledoc false

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
  @moduledoc """
  RFC 4506, Section 4.2 - Unsigned Integer
  """

  @behaviour XDR.Type.Base

  alias XDR.Type.Base
  import XDR.Util.Macros
  import XDR.Type.Uint.Validation

  @typedoc """
  Integer between 0 and 2^32 - 1
  """
  @type t :: 0..4294967295
  @type xdr :: Base.xdr

  @length 4

  @doc false
  def length, do: @length

  @doc false
  @spec new(uint :: t) :: {:ok, uint :: t} | {:error, :invalid}
  def new(uint \\ 0)
  def new(uint) when is_valid_uint?(uint), do: {:ok, uint}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 4-byte unsigned integer
  """
  @spec valid?(uint :: t) :: boolean
  def valid?(uint), do: is_valid_uint?(uint)

  @doc """
  Encodes an unsigned integer into a 4-byte binary
  """
  @spec encode(uint :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(uint) when not is_integer(uint), do: {:error, :invalid}
  def encode(uint) when not is_valid_uint?(uint), do: {:error, :out_of_bounds}
  def encode(uint), do: {:ok, <<uint :: big-unsigned-integer-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an unsigned integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {uint :: t, rest :: Base.xdr}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<uint :: big-unsigned-integer-size(32), rest :: binary>>), do: {:ok, {uint, rest}}
  def decode(_), do: {:error, :invalid}
end
