defmodule XDR.Type.FixedOpaque do
  @moduledoc """
  RFC 4506, Section 4.9 - Fixed-length Opaque data
  """

  alias XDR.Type.Base
  alias XDR.Util
  import XDR.Util.Guards

  @typedoc """
  A binary of any length
  """
  @type t :: binary
  @type len :: non_neg_integer
  @type xdr :: Base.xdr()
  @type decode_error :: {:error, :invalid | :out_of_bounds}

  defguard is_fixed_opaque(opaque, len)
           when is_binary(opaque) and is_integer(len) and byte_size(opaque) === len

  defmacro __using__(len: len) do
    if not (is_integer(len) and len >= 0) do
      raise "invalid length"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(len)
      def new(opaque), do: unquote(__MODULE__).new(opaque, unquote(len))
      def valid?(opaque), do: unquote(__MODULE__).valid?(opaque, unquote(len))
      def encode(opaque), do: unquote(__MODULE__).encode(opaque, unquote(len))
      def decode(opaque), do: unquote(__MODULE__).decode(opaque, unquote(len))
    end
  end

  @doc false
  @spec new(opaque :: t, len :: len) :: {:ok, opaque :: t} | {:error, :invalid}
  def new(opaque \\ <<>>, len)
  def new(opaque, len) when is_fixed_opaque(opaque, len), do: {:ok, opaque}
  def new(_, _), do: {:error, :invalid}

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(opaque :: t, len :: len) :: boolean
  def valid?(opaque, len), do: is_fixed_opaque(opaque, len)

  @doc """
  Encodes a fixed opaque binary by appending any necessary padding
  """
  @spec encode(opaque :: t, len :: len) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(opaque, len) when not is_fixed_opaque(opaque, len), do: {:error, :invalid}
  def encode(opaque, _) when required_padding(opaque) === 0, do: {:ok, opaque}
  def encode(opaque, _) when required_padding(opaque) === 1, do: {:ok, opaque <> <<0>>}
  def encode(opaque, _) when required_padding(opaque) === 2, do: {:ok, opaque <> <<0, 0>>}
  def encode(opaque, _) when required_padding(opaque) === 3, do: {:ok, opaque <> <<0, 0, 0>>}
  def encode(opaque, _) when required_padding(opaque) === 4, do: {:ok, opaque}

  @doc """
  Decodes an fixed opaque xdr binary by truncating it to the desired length
  """
  @spec decode(xdr :: xdr, len :: len) :: {:ok, {opaque :: t, rest :: Base.xdr()}} | decode_error
  def decode(xdr, _) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(xdr, len) when len > byte_size(xdr), do: {:error, :out_of_bounds}

  def decode(xdr, len) do
    padding_len = Util.required_padding(len)

    <<opaque::bytes-size(len), padding::bytes-size(padding_len), rest::binary>> = xdr

    case padding do
      <<>> -> {:ok, {opaque, rest}}
      <<0>> -> {:ok, {opaque, rest}}
      <<0, 0>> -> {:ok, {opaque, rest}}
      <<0, 0, 0>> -> {:ok, {opaque, rest}}
      _ -> {:error, :invalid_padding}
    end
  end
end
