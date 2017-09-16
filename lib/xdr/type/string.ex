defmodule XDR.Type.String.Validation do
  require Math

  @max_len Math.pow(2, 32) - 1

  defmacro is_valid_string?(string, max_len) do
    quote do
      is_bitstring(unquote(string))
      and is_integer(unquote(max_len))
      and unquote(max_len) <= unquote(@max_len)
      and byte_size(unquote(string)) <= unquote(max_len)
    end
  end
end

defmodule XDR.Type.String do
  require Math
  import XDR.Type.String.Validation
  alias XDR.Type.VariableOpaque

  @typedoc """
  A bitstrng of max-length 2^32 - 1
  """
  @type t :: String.t
  @type decode_error :: VariableOpaque.decode_error
  @type max :: VariableOpaque.max
  @type xdr :: VariableOpaque.xdr

  @max_len Math.pow(2, 32) - 1

  defmacro __using__(opts \\ []) do
    len = Keyword.get(opts, :len, @max_len)

    if len > @max_len do
      raise "max length too large"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(len)
      def valid?(string), do: unquote(__MODULE__).valid?(string, unquote(len))
      def encode(string), do: unquote(__MODULE__).encode(string, unquote(len))
      def decode(string), do: unquote(__MODULE__).decode(string, unquote(len))

      defoverridable [length: 0, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc """
  Determines if a value is a bitstring of a valid length
  """
  @spec valid?(any, max_len :: __MODULE__.max) :: boolean
  def valid?(string, max_len \\ @max_len)
  def valid?(string, max_len), do: is_valid_string?(string, max_len)

  @doc """
  Encodes a valid string by prepending the 4-byte length and appending any necessary padding
  """
  @spec encode(string :: __MODULE__.t, max_len :: __MODULE__.max) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(string, max_len \\ @max_len)
  def encode(string, max_len) when not is_valid_string?(string, max_len), do: {:error, :invalid}
  def encode(string, max_len), do: VariableOpaque.encode(string, max_len)

  @doc """
  Decodes a valid string xdr binary, removing the 4-byte length and any provided padding
  """
  @spec decode(xdr :: __MODULE__.xdr, max_len :: __MODULE__.max) :: {:ok, string :: __MODULE__.t} | __MODULE__.decode_error
  def decode(xdr, max_len \\ @max_len)
  def decode(xdr, max_len) do
    case VariableOpaque.decode(xdr, max_len) do
      {:ok, binary} -> {:ok, String.graphemes(binary) |> Enum.join("")}
      {:error, reason} -> {:error, reason}
    end
  end
end
