defmodule XDR.Type.VariableOpaque.Validation do
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
  require Math
  import XDR.Util.Macros
  import XDR.Type.VariableOpaque.Validation
  alias XDR.Type.Uint

  @typedoc """
  A binary of max-length 2^32 - 1
  """
  @type t :: binary
  @type max :: Uint.t
  @type xdr :: <<_ :: _*32>>
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

      def length, do: unquote(max)
      defdelegate new, to: unquote(__MODULE__)
      def new(opaque), do: unquote(__MODULE__).new(opaque, unquote(max))
      def valid?(opaque), do: unquote(__MODULE__).valid?(opaque, unquote(max))
      def encode(opaque), do: unquote(__MODULE__).encode(opaque, unquote(max))
      def decode(opaque), do: unquote(__MODULE__).decode(opaque, unquote(max))

      defoverridable [length: 0, new: 0, new: 1, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc false
  def new(opaque \\ <<>>, max \\ @max)
  def new(opaque, max) when is_valid_variable_opaque?(opaque, max), do: {:ok, opaque}
  def new(_, _), do: {:error, :invalid}

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(any, max :: max) :: boolean
  def valid?(opaque, max \\ @max)
  def valid?(opaque, max), do: is_valid_variable_opaque?(opaque, max)

  @doc """
  Encodes a valid variable opaque binary, prepending the 4-byte length of the binary and appending any necessary padding
  """
  @spec encode(opaque :: t, max :: max) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(opaque, max \\ @max)
  def encode(opaque, max) when not is_valid_variable_opaque?(opaque, max), do: {:error, :invalid}
  def encode(opaque, _), do: {:ok, encode_opaque(opaque, required_padding(opaque))}

  @doc """
  Decodes a valid variable opaque xdr binary, removing the 4-byte length and any provided padding
  """
  @spec decode(xdr :: xdr, max :: max) :: {:ok, opaque :: t} | decode_error
  def decode(xdr, max \\ @max)
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(_, max) when max > @max, do: {:error, :max_length_too_large}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), _ :: binary>>, max)
      when defined_len > max, do: {:error, :xdr_length_exceeds_defined_max}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), rest :: binary>>, _)
      when defined_len > byte_size(rest), do: {:error, :invalid_xdr_length}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), rest :: binary>>, _) do
    <<opaque :: binary-size(defined_len), padding :: binary>> = rest
    case padding do
      <<>> -> {:ok, opaque}
      <<0>> -> {:ok, opaque}
      <<0, 0>> -> {:ok, opaque}
      <<0, 0, 0>> -> {:ok, opaque}
      _ -> {:error, :invalid_padding}
    end
  end

  #-------------------------------------------------------------------------#
  # HELPERS
  #-------------------------------------------------------------------------#
  # prepends 4-byte length and appends any necessary padding
  @spec encode_opaque(opaque :: t, padding_length :: 0..3) :: xdr :: xdr
  defp encode_opaque(opaque, 0), do: encode_length(opaque) <> opaque
  defp encode_opaque(opaque, 1), do: encode_length(opaque) <> opaque <> <<0>>
  defp encode_opaque(opaque, 2), do: encode_length(opaque) <> opaque <> <<0, 0>>
  defp encode_opaque(opaque, 3), do: encode_length(opaque) <> opaque <> <<0, 0, 0>>
  defp encode_opaque(opaque, 4), do: encode_length(opaque) <> opaque

  # helper for converting a binary or it's length to a 4-byte binary
  @spec encode_length(opaque :: t) :: opaque_length :: Uint.xdr
  defp encode_length(opaque) when is_binary(opaque), do: byte_size(opaque) |> encode_length
  @spec encode_length(len :: Uint.t) :: opaque_length :: Uint.xdr
  defp encode_length(len) when is_integer(len), do: Uint.encode(len) |> elem(1)
end
