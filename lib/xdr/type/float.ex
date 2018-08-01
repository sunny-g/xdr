defmodule XDR.Type.Float do
  @moduledoc """
  RFC 4506, Section 4.6 - Single-precision Floating Point
  """

  alias XDR.Type.Base
  import XDR.Util.Macros

  @behaviour XDR.Type.Base

  @typedoc """
  Single-precision float
  """
  @type t :: number
  @type xdr :: Base.xdr()

  @length 4

  defguard is_xdr_float(float) when is_float(float) or is_integer(float)

  defmacro __using__(_ \\ []) do
    quote do
      defdelegate length(), to: unquote(__MODULE__)
      defdelegate new(float \\ 0.0), to: unquote(__MODULE__)
      defdelegate valid?(float), to: unquote(__MODULE__)
      defdelegate encode(float), to: unquote(__MODULE__)
      defdelegate decode(float), to: unquote(__MODULE__)
    end
  end

  @doc false
  def length, do: @length

  @doc false
  @spec new(float :: t) :: {:ok, float :: t} | {:error, :invalid}
  def new(float \\ 0.0)
  def new(float) when is_xdr_float(float), do: {:ok, float}
  def new(_), do: {:error, :invalid}

  @doc """
  Determines if a value is a valid 4-byte float or integer
  """
  @spec valid?(float :: t) :: boolean
  def valid?(float), do: is_xdr_float(float)

  @doc """
  Encodes a single-precision float or integer into a 4-byte binary
  """
  @spec encode(float :: t) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(float) when not is_xdr_float(float), do: {:error, :invalid}
  def encode(float), do: {:ok, <<float::big-signed-float-size(32)>>}

  @doc """
  Decodes a 4-byte binary into an single-precision float
  """
  @spec decode(xdr :: xdr) ::
          {:ok, {float :: t, rest :: Base.xdr()}} | {:error, :invalid | :out_of_bounds}
  def decode(xdr) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(<<float::big-signed-float-size(32), rest::binary>>), do: {:ok, {float, rest}}
  def decode(_), do: {:error, :invalid}
end
