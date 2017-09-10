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

  @type t :: binary
  @type max :: Uint.t
  @type xdr :: <<_ :: _*32>>
  @type decode_error :: {:error,
    :invalid |
    :max_length_too_large |
    :xdr_length_exceeds_max |
    :invalid_xdr_length |
    :invalid_padding
  }

  @len_size 32
  @max_len Math.pow(2, 32) - 1

  @doc """
  """
  @spec is_valid?(any, max_len :: __MODULE__.max) :: boolean
  def is_valid?(opaque, max_len \\ @max_len)
  def is_valid?(opaque, max_len), do: is_valid_variable_opaque?(opaque, max_len)

  @doc """
  """
  @spec encode(opaque :: __MODULE__.t, max_len :: __MODULE__.max) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(opaque, max_len \\ @max_len)
  def encode(opaque, max_len) when not is_valid_variable_opaque?(opaque, max_len), do: {:error, :invalid}
  def encode(opaque, _), do: {:ok, encode_opaque(opaque, required_padding(opaque))}

  @doc """
  """
  @spec decode(xdr :: __MODULE__.xdr, max_len :: __MODULE__.max) :: {:ok, opaque :: __MODULE__.t} | __MODULE__.decode_error
  def decode(xdr, max_len \\ @max_len)
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(_, max_len) when max_len > @max_len, do: {:error, :max_length_too_large}
  def decode(<<defined_len :: big-unsigned-integer-size(@len_size), _ :: binary>>, max_len)
      when defined_len > max_len, do: {:error, :xdr_length_exceeds_max}
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
