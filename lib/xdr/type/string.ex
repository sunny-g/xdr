defmodule XDR.Type.String do
  @moduledoc """
  RFC 4506, Section 4.11 - String
  """

  require Math
  alias XDR.Type.Base
  alias XDR.Type.VariableOpaque

  @typedoc """
  A bitstrng of max-length 2^32 - 1
  """
  @type t :: String.t()
  @type xdr :: VariableOpaque.xdr()
  @type max :: VariableOpaque.max()
  @type decode_error :: VariableOpaque.decode_error()

  @max_len Math.pow(2, 32) - 1

  defguard is_xdr_string(string, max_len)
           when is_bitstring(string) and is_integer(max_len) and max_len <= @max_len and
                  byte_size(string) <= max_len

  defmacro __using__(spec) do
    max_len = Keyword.get(spec, :max_len, @max_len)

    if max_len > @max_len do
      raise "max length too large"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: :variable
      def new, do: unquote(__MODULE__).new
      def new(string), do: unquote(__MODULE__).new(string, unquote(max_len))
      def valid?(string), do: unquote(__MODULE__).valid?(string, unquote(max_len))
      def encode(string), do: unquote(__MODULE__).encode(string, unquote(max_len))
      def decode(string), do: unquote(__MODULE__).decode(string, unquote(max_len))

      defoverridable length: 0, new: 0, new: 1, valid?: 1, encode: 1, decode: 1
    end
  end

  @doc false
  @spec new(string :: t, max_len :: max) :: {:ok, string :: t} | {:error, :invalid}
  def new(string \\ "", max_len \\ @max_len)
  def new(string, max_len) when is_xdr_string(string, max_len), do: {:ok, string}
  def new(_, _), do: {:error, :invalid}

  @doc """
  Determines if a value is a bitstring of a valid length
  """
  @spec valid?(string :: t, max_len :: max) :: boolean
  def valid?(string, max_len \\ @max_len)
  def valid?(string, max_len), do: is_xdr_string(string, max_len)

  @doc """
  Encodes a valid string by prepending the 4-byte length and appending any necessary padding
  """
  @spec encode(string :: t, max_len :: max) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(string, max_len \\ @max_len)
  def encode(string, max_len) when not is_xdr_string(string, max_len), do: {:error, :invalid}
  def encode(string, max_len), do: VariableOpaque.encode(string, max_len)

  @doc """
  Decodes a valid string xdr binary, removing the 4-byte length and any provided padding
  """
  @spec decode(xdr :: xdr, max_len :: max) ::
          {:ok, {string :: t, rest :: Base.xdr()}} | decode_error
  def decode(xdr, max_len \\ @max_len)

  def decode(xdr, max_len) do
    case VariableOpaque.decode(xdr, max_len) do
      {:error, reason} ->
        {:error, reason}

      {:ok, {binary, rest}} ->
        result =
          binary
          |> String.graphemes()
          |> Enum.join("")

        {:ok, {result, rest}}
    end
  end
end
