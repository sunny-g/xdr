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
  @type t :: bitstring
  @type decode_error :: VariableOpaque.decode_error
  @type max :: VariableOpaque.max
  @type xdr :: VariableOpaque.xdr

  @max_len Math.pow(2, 32) - 1

  @doc """
  Determines if a value is a bitstring of a valid length
  """
  @spec is_valid?(any, max_len :: __MODULE__.max) :: boolean
  def is_valid?(string, max_len \\ @max_len)
  def is_valid?(string, max_len), do: is_valid_string?(string, max_len)

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
  def decode(xdr, max_len), do: VariableOpaque.decode(xdr, max_len)
end
