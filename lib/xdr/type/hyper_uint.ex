defmodule XDR.Type.HyperUint.Validation do
  @moduledoc false

  require Math

  @min_hyper_uint 0
  @max_hyper_uint Math.pow(2, 64) - 1

  defmacro is_valid_hyper_uint?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_hyper_uint)
      and unquote(int) <= unquote(@max_hyper_uint)
    end
  end
end

defmodule XDR.Type.HyperUint do
  @moduledoc """
  RFC 4506, Section 4.5 - Unsigned Hyper Integer
  """

  alias XDR.Type.Base
  import XDR.Util.Macros
  import XDR.Type.HyperUint.Validation

  @behaviour XDR.Type.Base

  @typedoc """
  Hyper unsigned integer between 0 and 2^64 - 1
  """
  @type t :: 0..18446744073709551615
  @type xdr :: <<_ :: _*64>>

  @length 8

  @doc false
  def length, do: @length

  @doc false
  @spec new(hyper_uint :: t) :: {:ok, hyper_uint :: t} | {:error, :invalid}
  def new(hyper_uint \\ 0)
  def new(hyper_uint) when is_valid_hyper_uint?(hyper_uint), do: {:ok, hyper_uint}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte hyper unsigned integer
  """
  @spec valid?(hyper_uint :: t) :: boolean
  def valid?(hyper_uint), do: is_valid_hyper_uint?(hyper_uint)

  @doc """
  Encodes a hyper unsigned integer into an 8-byte binary
  """
  @spec encode(hyper_uint :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_uint) when not is_integer(hyper_uint), do: {:error, :invalid}
  def encode(hyper_uint) when not is_valid_hyper_uint?(hyper_uint), do: {:error, :out_of_bounds}
  def encode(hyper_uint), do: {:ok, <<hyper_uint :: big-unsigned-integer-size(64)>>}

  @doc """
  Decodes a 8-byte binary into a hyper unsigned integer
  """
  @spec decode(xdr :: xdr) :: {:ok, {hyper_uint :: t, rest :: Base.xdr}} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(<<hyper_uint :: big-unsigned-integer-size(64), rest :: binary>>), do: {:ok, {hyper_uint, rest}}
  def decode(_), do: {:error, :invalid}
end
