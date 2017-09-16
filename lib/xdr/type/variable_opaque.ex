defmodule XDR.Type.VariableOpaque.Validation do
  require Math

  @max_len Math.pow(2, 32) - 1

  defmacro is_valid_variable_opaque?(opaque, max_len) do
    quote do
      is_binary(unquote(opaque))
      and is_integer(unquote(max_len))
      and unquote(max_len) <= unquote(@max_len)
      and byte_size(unquote(opaque)) <= unquote(max_len)
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
  @type max_len :: Uint.t
  @type xdr :: <<_ :: _*32>>
  @type decode_error :: {:error,
    :invalid |
    :max_length_too_large |
    :xdr_length_exceeds_defined_max |
    :invalid_xdr_length |
    :invalid_padding
  }

  @len_size 32
  @max_len Math.pow(2, 32) - 1

  defmacro __using__(opts \\ []) do
    len = Keyword.get(opts, :len, @max_len)

    if len > @max_len do
      raise "max length too large"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(len)
      def valid?(opaque), do: unquote(__MODULE__).valid?(opaque, unquote(len))
      def encode(opaque), do: unquote(__MODULE__).encode(opaque, unquote(len))
      def decode(opaque), do: unquote(__MODULE__).decode(opaque, unquote(len))

      defoverridable [length: 0, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(any, max_len :: __MODULE__.max_len) :: boolean
  def valid?(opaque, max_len \\ @max_len)
  def valid?(opaque, max_len), do: is_valid_variable_opaque?(opaque, max_len)

  @doc """
  Encodes a valid variable opaque binary, prepending the 4-byte length of the binary and appending any necessary padding
  """
  @spec encode(opaque :: __MODULE__.t, max_len :: __MODULE__.max_len) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(opaque, max_len \\ @max_len)
  def encode(opaque, max_len) when not is_valid_variable_opaque?(opaque, max_len), do: {:error, :invalid}
  def encode(opaque, _), do: {:ok, encode_opaque(opaque, required_padding(opaque))}

  @doc """
  Decodes a valid variable opaque xdr binary, removing the 4-byte length and any provided padding
  """
  @spec decode(xdr :: __MODULE__.xdr, max_len :: __MODULE__.max_len) :: {:ok, opaque :: __MODULE__.t} | __MODULE__.decode_error
  def decode(xdr, max_len \\ @max_len)
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(_, max_len) when max_len > @max_len, do: {:error, :max_length_too_large}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), _ :: binary>>, max_len)
      when defined_len > max_len, do: {:error, :xdr_length_exceeds_defined_max}
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
  @spec encode_opaque(opaque :: __MODULE__.t, padding_length :: 0..3) :: xdr :: __MODULE__.xdr
  defp encode_opaque(opaque, 0), do: encode_length(opaque) <> opaque
  defp encode_opaque(opaque, 1), do: encode_length(opaque) <> opaque <> <<0>>
  defp encode_opaque(opaque, 2), do: encode_length(opaque) <> opaque <> <<0, 0>>
  defp encode_opaque(opaque, 3), do: encode_length(opaque) <> opaque <> <<0, 0, 0>>
  defp encode_opaque(opaque, 4), do: encode_length(opaque) <> opaque

  # helper for converting a binary or it's length to a 4-byte binary
  @spec encode_length(opaque :: __MODULE__.t) :: opaque_length :: Uint.xdr
  defp encode_length(opaque) when is_binary(opaque), do: byte_size(opaque) |> encode_length
  @spec encode_length(len :: Uint.t) :: opaque_length :: Uint.xdr
  defp encode_length(len) when is_integer(len), do: Uint.encode(len) |> elem(1)
end
