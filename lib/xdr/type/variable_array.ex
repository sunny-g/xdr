defmodule XDR.Type.VariableArray do
  @moduledoc """
  RFC 4506, Section 4.13 - Variable-length Array
  """

  require Math
  require OK
  import XDR.Util.Macros

  alias XDR.Type.{
    Base,
    FixedArray,
    Uint
  }

  @typedoc """
  A binary of any length
  """
  @type t :: list
  @type max :: Uint.t()
  @type xdr :: Base.xdr()
  @type decode_error :: {:error, :invalid | :xdr_too_small}

  @len_size 32
  @max_len Math.pow(2, 32) - 1

  defmacro __using__(opts \\ []) do
    max = Keyword.get(opts, :max_len, @max_len)
    type = Keyword.get(opts, :type)

    if not (is_integer(max) and max >= 0 and max <= @max_len) do
      raise "invalid length"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: :variable
      def new, do: unquote(__MODULE__).new([], unquote(type), unquote(max))
      def new(array), do: unquote(__MODULE__).new(array, unquote(type), unquote(max))
      def valid?(array), do: unquote(__MODULE__).valid?(array, unquote(type), unquote(max))
      def encode(array), do: unquote(__MODULE__).encode(array, unquote(type), unquote(max))
      def decode(array), do: unquote(__MODULE__).decode(array, unquote(type), unquote(max))

      defoverridable length: 0, new: 0, new: 1, valid?: 1, encode: 1, decode: 1
    end
  end

  @doc false
  @spec new(array :: t, type :: module, max :: max) ::
          {:ok, array :: t} | {:error, reason :: :invalid}
  def new(array, type, max \\ @max_len)

  def new(array, type, max) do
    if valid?(array, type, max), do: {:ok, array}, else: {:error, :invalid}
  end

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(array :: t, type :: module, max :: max) :: boolean
  def valid?(array, type, max \\ @max_len)

  def valid?(array, type, max) do
    is_list(array) and is_atom(type) and is_integer(max) and max <= @max_len and
      length(array) <= max and Enum.all?(array, &type.valid?/1)
  end

  @doc """
  Encodes a fixed array into a binary
  """
  @spec encode(array :: t, type :: module, max :: max) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(array, type, max \\ @max_len)

  def encode(array, type, max) do
    if valid?(array, type, max) do
      OK.with do
        len = length(array)
        encoded <- FixedArray.encode(array, type, len)
        encoded_len <- Uint.encode(len)
        {:ok, encoded_len <> encoded}
      end
    else
      {:error, :invalid}
    end
  end

  @doc """
  Decodes an fixed array xdr binary by truncating it to the desired length
  """
  @spec decode(xdr :: xdr, type :: module, max :: max) ::
          {:ok, {array :: t, rest :: Base.xdr()}} | decode_error
  def decode(xdr, type, max \\ @max_len)
  def decode(xdr, _, _) when not is_valid_xdr(xdr), do: {:error, :invalid}
  def decode(_, _, max) when max > @max_len, do: {:error, :max_length_too_large}

  def decode(<<xdr_len::big-unsigned-integer-size(@len_size), _::binary>>, _, max)
      when xdr_len > max,
      do: {:error, :xdr_length_exceeds_defined_max}

  def decode(<<xdr_len::big-unsigned-integer-size(@len_size), rest::binary>>, _, _)
      when xdr_len * 4 > byte_size(rest),
      do: {:error, :invalid_xdr_length}

  def decode(<<xdr_len::big-unsigned-integer-size(@len_size), rest::binary>>, type, _) do
    FixedArray.decode(rest, type, xdr_len)
  end
end
