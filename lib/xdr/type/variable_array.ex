defmodule XDR.Type.VariableArray do
  require Math
  import XDR.Util.Macros
  alias XDR.Type.Uint

  @typedoc """
  A binary of any length
  """
  @type t :: list
  @type max :: Uint.t
  @type xdr :: <<_ :: _*32>>
  @type decode_error :: {:error, :invalid | :xdr_too_small}

  @len_size 32
  @max_len Math.pow(2, 32) - 1

  defmacro __using__(opts \\ []) do
    max = Keyword.get(opts, :max, @max_len)
    type = Keyword.get(opts, :type)

    if not (is_integer(max) and max >= 0 and max <= @max_len) do
      raise "invalid length"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(max)
      def valid?(array), do: unquote(__MODULE__).valid?(array, unquote(type), unquote(max))
      def encode(array), do: unquote(__MODULE__).encode(array, unquote(type), unquote(max))
      def decode(array), do: unquote(__MODULE__).decode(array, unquote(type), unquote(max))

      defoverridable [length: 0, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(any, type :: module, max :: max) :: boolean
  def valid?(array, type, max \\ @max_len)
  def valid?(array, type, max) do
    is_list(array)
    and is_atom(type)
    and is_integer(max)
    and max <= @max_len
    and length(array) <= max
    and Enum.all?(array, &type.valid?/1)
  end

  @doc """
  Encodes a fixed array into a binary
  """
  @spec encode(array :: t, type :: module, max :: max) :: {:ok, xdr :: xdr} | {:error, :invalid}
  def encode(array, type, max \\ @max_len)
  def encode(array, type, max) do
    case valid?(array, type, max) do
      true -> {:ok, array_to_xdr(array, type, max)}
      false -> {:error, :invalid}
    end
  end

  @doc """
  Decodes an fixed array xdr binary by truncating it to the desired length
  """
  @spec decode(xdr :: xdr, type :: module, max :: max) :: {:ok, array :: t} | decode_error
  def decode(xdr, type, max \\ @max_len)
  def decode(xdr, _, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(_, _, max) when max > @max_len, do: {:error, :max_length_too_large}
  def decode(<<xdr_len :: big-unsigned-integer-size(@len_size), _ :: binary>>, _, max)
      when xdr_len > max, do: {:error, :xdr_length_exceeds_defined_max}
  def decode(<<xdr_len :: big-unsigned-integer-size(@len_size), rest :: binary>>, _, _)
      when (xdr_len * 4) > byte_size(rest), do: {:error, :invalid_xdr_length}
  def decode(xdr, type, max), do: xdr_to_array(xdr, type, max)

  #-------------------------------------------------------------------------#
  # HELPERS
  #-------------------------------------------------------------------------#
  # reduces each array element into an encoded binary
  defp array_to_xdr(array, type, max) do
    Enum.reduce(array, <<max :: big-unsigned-integer-size(@len_size)>>, fn(elem, xdr) ->
      encoded_elem = type.encode(elem) |> elem(1)
      xdr <> encoded_elem
    end)
  end

  # decodes each element of a binary
  defp xdr_to_array(<<xdr_len :: big-unsigned-integer-size(@len_size), xdr :: binary>>, type, _) do
    decoded = case function_exported?(type, :length, 0) do
      true -> decode_fixed_type(xdr, type, xdr_len, [])
      false -> decode_variable_type(xdr, type, xdr_len, [])
    end

    if is_list(decoded), do: {:ok, Enum.reverse(decoded)}, else: {:error, decoded}
  end

  # decodes an XDR of fixed type elements
  defp decode_fixed_type(_, _, 0, array), do: array
  defp decode_fixed_type(xdr, type, array_length, array) do
    elem_length = type.length
    <<elem :: bits-size(elem_length), rest :: binary>> = xdr

    case type.decode(elem) do
      {:ok, val} -> decode_fixed_type(rest, type, array_length - 1, [val | array])
      {:error, reason} -> reason
    end
  end

  # decodes an XDR of variable type elements
  defp decode_variable_type(_, _, 0, array), do: array
  defp decode_variable_type(xdr, type, array_length, array) do
    <<elem_length :: big-unsigned-integer-size(@len_size), rest :: binary>> = xdr
    <<elem :: bits-size(elem_length), _padding :: binary>> = rest

    case type.decode(elem) do
      {:ok, val} -> decode_variable_type(rest, type, array_length - 1, [val | array])
      {:error, reason} -> reason
    end
  end
end
