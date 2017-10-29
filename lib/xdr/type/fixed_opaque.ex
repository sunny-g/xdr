defmodule XDR.Type.FixedOpaque.Validation do
  defmacro is_valid_fixed_opaque?(opaque, len) do
    quote do
      is_binary(unquote(opaque))
      and is_integer(unquote(len))
      and byte_size(unquote(opaque)) === unquote(len)
    end
  end
end

defmodule XDR.Type.FixedOpaque do
  alias XDR.Util
  import XDR.Util.Macros
  import XDR.Type.FixedOpaque.Validation

  @typedoc """
  A binary of any length
  """
  @type t :: binary
  @type len :: non_neg_integer
  @type xdr :: <<_ :: _*32>>
  @type decode_error :: {:error, :invalid | :out_of_bounds}

  defmacro __using__(len: len) do
    if not (is_integer(len) and len >= 0) do
      raise "invalid length"
    end

    bit_length = len * 8

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(bit_length)
      def new(opaque), do: unquote(__MODULE__).new(opaque, unquote(len))
      def valid?(opaque), do: unquote(__MODULE__).valid?(opaque, unquote(len))
      def encode(opaque), do: unquote(__MODULE__).encode(opaque, unquote(len))
      def decode(opaque), do: unquote(__MODULE__).decode(opaque, unquote(len))
    end
  end

  @doc false
  def new(opaque \\ <<>>, len)
  def new(opaque, len) when is_valid_fixed_opaque?(opaque, len), do: {:ok, opaque}
  def new(_, _), do: {:error, :invalid}

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(t, len :: len) :: boolean
  def valid?(opaque, len), do: is_valid_fixed_opaque?(opaque, len)

  @doc """
  Encodes a fixed opaque binary by appending any necessary padding
  """
  @spec encode(opaque :: t, len :: len) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(opaque, len) when not is_valid_fixed_opaque?(opaque, len), do: {:error, :invalid}
  def encode(opaque, _) when required_padding(opaque) === 0, do: {:ok, opaque}
  def encode(opaque, _) when required_padding(opaque) === 1, do: {:ok, opaque <> <<0>>}
  def encode(opaque, _) when required_padding(opaque) === 2, do: {:ok, opaque <> <<0, 0>>}
  def encode(opaque, _) when required_padding(opaque) === 3, do: {:ok, opaque <> <<0, 0, 0>>}
  def encode(opaque, _) when required_padding(opaque) === 4, do: {:ok, opaque}

  @doc """
  Decodes an fixed opaque xdr binary by truncating it to the desired length
  """
  @spec decode(xdr :: xdr, len :: len) :: {:ok, opaque :: t} | decode_error
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr, len) when len > byte_size(xdr), do: {:error, :out_of_bounds}
  def decode(xdr, len) do
    padding_len = Util.required_padding(len)

    <<opaque :: binary-size(len), padding :: binary-size(padding_len), rest :: binary>> = xdr
    case padding do
      <<>> -> {:ok, {opaque, rest}}
      <<0>> -> {:ok, {opaque, rest}}
      <<0, 0>> -> {:ok, {opaque, rest}}
      <<0, 0, 0>> -> {:ok, {opaque, rest}}
      _ -> {:error, :invalid_padding}
    end
  end
end
