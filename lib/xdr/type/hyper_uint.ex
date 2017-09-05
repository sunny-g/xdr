defmodule XDR.Type.HyperUint.Validation do
  require Math

  @min_hyper_uint 0
  @max_hyper_uint Math.pow(2, 64) - 1

  defmacro is_valid?(int) do
    quote do
      is_integer(unquote(int))
      and unquote(int) >= unquote(@min_hyper_uint)
      and unquote(int) <= unquote(@max_hyper_uint)
    end
  end
end

defmodule XDR.Type.HyperUint do
  require XDR.Type.HyperUint.Validation

  @typedoc """
  Hyper unsigned integer between 0 and 2^64 - 1
  """
  @type t :: 0..18446744073709551615

  @doc """
  Determines if a value is a valid 8-byte hyper unsigned integer
  """
  @spec is_valid?(hyper_uint :: __MODULE__.t) :: boolean
  def is_valid?(hyper_uint), do: XDR.Type.HyperUint.Validation.is_valid?(hyper_uint)

  @doc """
  Encodes a hyper unsigned integer into an 8-byte binary
  """
  @spec encode(hyper_uint :: __MODULE__.t) :: {:ok, xdr :: <<_ :: 64>>} | {:error, :invalid | :out_of_bounds}
  def encode(hyper_uint) when not is_integer(hyper_uint), do: {:error, :invalid}
  def encode(hyper_uint) when not XDR.Type.HyperUint.Validation.is_valid?(hyper_uint), do: {:error, :out_of_bounds}
  def encode(hyper_uint), do: {:ok, <<hyper_uint :: big-unsigned-integer-size(64)>>}

  @doc """
  Decodes a 8-byte binary into a hyper unsigned integer
  """
  @spec decode(xdr :: <<_ :: 64>>) :: {:ok, hyper_uint :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_binary(xdr), do: {:error, :invalid}
  def decode(xdr) when bit_size(xdr) > 64, do: {:error, :out_of_bounds}
  def decode(<<hyper_uint :: big-unsigned-integer-size(64)>>), do: {:ok, hyper_uint}
  def decode(_), do: {:error, :invalid}
end
