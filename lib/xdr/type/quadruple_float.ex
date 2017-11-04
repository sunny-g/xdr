defmodule XDR.Type.QuadrupleFloat do
  @moduledoc """
  RFC 4506, Section 4.8 - Quadruple-precision Floating Point (not implemented)
  """

  alias XDR.Type.Base

  @behaviour XDR.Type.Base

  @typedoc """
  Quadruple-precision float
  """
  @type t :: number
  @type xdr :: Base.xdr

  @length 16

  @doc false
  def length, do: @length

  @doc false
  @spec new(float :: t) :: {:ok, float :: t} | {:error, :invalid}
  def new(float \\ 0.0)
  def new(_), do: {:error, :not_implemented}

  @doc false
  @spec valid?(float :: t) :: boolean
  def valid?(_), do: false

  @doc false
  @spec encode(float :: t) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(_), do: {:error, :not_implemented}

  @doc false
  @spec decode(xdr :: xdr) :: {:ok, {float :: t, rest :: Base.xdr}} | {:error, :invalid | :out_of_bounds}
  def decode(_), do: {:error, :not_implemented}
end
