defmodule XDR.Type.VariableOpaque.Validation do
  @moduledoc false

  require Math

  @max Math.pow(2, 32) - 1

  defmacro is_valid_variable_opaque?(opaque, max) do
    quote do
      is_binary(unquote(opaque))
      and is_integer(unquote(max))
      and unquote(max) <= unquote(@max)
      and byte_size(unquote(opaque)) <= unquote(max)
    end
  end
end

defmodule XDR.Type.VariableOpaque do
  @moduledoc """
  RFC 4506, Section 4.10 - Variable-length Opaque Data
  """

  require Math
  require OK
  import XDR.Util.Macros
  import XDR.Type.VariableOpaque.Validation
  alias XDR.Type.{Base, FixedOpaque, Uint}

  @typedoc """
  A binary of max-length 2^32 - 1
  """
  @type t :: binary
  @type max :: Uint.t
  @type xdr :: Base.xdr
  @type decode_error :: {:error,
    :invalid |
    :max_length_too_large |
    :xdr_length_exceeds_defined_max |
    :invalid_xdr_length |
    :invalid_padding
  }

  @len_size 32
  @max Math.pow(2, 32) - 1

  defmacro __using__(opts \\ []) do
    max = Keyword.get(opts, :max_len, @max)

    if max > @max do
      raise "max length too large"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: :variable
      def new, do: unquote(__MODULE__).new
      def new(opaque), do: unquote(__MODULE__).new(opaque, unquote(max))
      def valid?(opaque), do: unquote(__MODULE__).valid?(opaque, unquote(max))
      def encode(opaque), do: unquote(__MODULE__).encode(opaque, unquote(max))
      def decode(opaque), do: unquote(__MODULE__).decode(opaque, unquote(max))

      defoverridable [length: 0, new: 0, new: 1, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc false
  @spec new(opaque :: t, max :: max) :: {:ok, opaque :: t} | {:error, :invalid}
  def new(opaque \\ <<>>, max \\ @max)
  def new(opaque, max) when is_valid_variable_opaque?(opaque, max), do: {:ok, opaque}
  def new(_, _), do: {:error, :invalid}

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(opaque :: t, max :: max) :: boolean
  def valid?(opaque, max \\ @max)
  def valid?(opaque, max), do: is_valid_variable_opaque?(opaque, max)

  @doc """
  Encodes a valid variable opaque binary, prepending the 4-byte length of the binary and appending any necessary padding
  """
  @spec encode(opaque :: t, max :: max) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(opaque, max \\ @max)
  def encode(opaque, max) when not is_valid_variable_opaque?(opaque, max), do: {:error, :invalid}
  def encode(opaque, _) do
    OK.with do
      len = byte_size(opaque)
      encoded <- FixedOpaque.encode(opaque, len)
      encoded_len <- Uint.encode(len)
      {:ok, encoded_len <> encoded}
    end
  end

  @doc """
  Decodes a valid variable opaque xdr binary, removing the 4-byte length and any provided padding
  """
  @spec decode(xdr :: xdr, max :: max) :: {:ok, {opaque :: t, rest :: Base.xdr}} | decode_error
  def decode(xdr, max \\ @max)
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(_, max) when max > @max, do: {:error, :max_length_too_large}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), _ :: binary>>, max)
      when defined_len > max, do: {:error, :xdr_length_exceeds_defined_max}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), rest :: binary>>, _)
      when defined_len > byte_size(rest), do: {:error, :invalid_xdr_length}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), rest :: binary>>, _) do
    FixedOpaque.decode(rest, defined_len)
  end
end
