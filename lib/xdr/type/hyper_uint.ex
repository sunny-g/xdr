defmodule XDR.Type.HyperUint.Validation do
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
  @behaviour XDR.Type.Base

  import XDR.Util.Macros
  import XDR.Type.HyperUint.Validation

  @typedoc """
  Hyper unsigned integer between 0 and 2^64 - 1
  """
  @type t :: 0..18446744073709551615
  @type xdr :: <<_ :: 64>>

  @length 64

  @doc false
  def length, do: @length

  @doc false
  def new(hyper_uint \\ 0)
  def new(hyper_uint) when is_valid_hyper_uint?(hyper_uint), do: {:ok, hyper_uint}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 8-byte hyper unsigned integer
  """
  @spec valid?(any) :: boolean
  def valid?(hyper_uint), do: is_valid_hyper_uint?(hyper_uint)

  @doc """
  Encodes a hyper unsigned integer into an 8-byte binary
  """
  @spec encode(hyper_uint :: t) :: {:ok, xdr :: xdr} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_uint) when not is_integer(hyper_uint), do: {:error, :invalid}
  def encode(hyper_uint) when not is_valid_hyper_uint?(hyper_uint), do: {:error, :out_of_bounds}
  def encode(hyper_uint), do: {:ok, <<hyper_uint :: big-unsigned-integer-size(@length)>>}

  @doc """
  Decodes a 8-byte binary into a hyper unsigned integer
  """
  @spec decode(xdr :: xdr) :: {:ok, hyper_uint :: t} | {:error, :invalid}
  def decode(xdr) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) !== @length, do: {:error, :invalid}
  def decode(<<hyper_uint :: big-unsigned-integer-size(@length)>>), do: {:ok, hyper_uint}
  def decode(_), do: {:error, :invalid}
end
