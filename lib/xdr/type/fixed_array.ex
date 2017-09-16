defmodule XDR.Type.FixedArray do
  import XDR.Util.Macros

  @typedoc """
  A binary of any length
  """
  @type t :: list
  @type len :: non_neg_integer
  @type xdr :: <<_ :: _*32>>
  @type decode_error :: {:error, :invalid | :xdr_too_small}

  defmacro __using__(len: len, type: type) do
    if not (is_integer(len) and len >= 0) do
      raise "invalid length"
    end

    quote do
      @behaviour XDR.Type.Base

      def length, do: unquote(len)
      def valid?(array), do: unquote(__MODULE__).valid?(array, unquote(type), unquote(len))
      def encode(array), do: unquote(__MODULE__).encode(array, unquote(type), unquote(len))
      def decode(array), do: unquote(__MODULE__).decode(array, unquote(type), unquote(len))

      defoverridable [length: 0, valid?: 1, encode: 1, decode: 1]
    end
  end

  @doc """
  Determines if a value is a binary of a valid length
  """
  @spec valid?(any, type :: module, len :: __MODULE__.len) :: boolean
  def valid?(array, type, len) do
    is_list(array)
    and is_atom(type)
    and is_integer(len)
    and length(array) === len
    and Enum.all?(array, &type.valid?/1)
  end

  @doc """
  Encodes a fixed array into a binary
  """
  @spec encode(array :: __MODULE__.t, type :: module, len :: __MODULE__.len) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(array, type, len) do
    case valid?(array, type, len) do
      true -> {:ok, array_to_xdr(array, type)}
      false -> {:error, :invalid}
    end
  end

  @doc """
  Decodes an fixed array xdr binary by truncating it to the desired length
  """
  @spec decode(xdr :: __MODULE__.xdr, type :: module, len :: __MODULE__.len) :: {:ok, array :: __MODULE__.t} | __MODULE__.decode_error
  def decode(xdr, _, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr, _, len) when (len * 4) > byte_size(xdr), do: {:error, :xdr_too_small}
  def decode(xdr, type, len), do: xdr_to_array(xdr, type, len)

  #-------------------------------------------------------------------------#
  # HELPERS
  #-------------------------------------------------------------------------#
  # reduces each array element into an encoded binary
  defp array_to_xdr(array, type) do
    Enum.reduce(array, <<>>, fn(elem, xdr) ->
      encoded_elem = type.encode(elem) |> elem(1)
      xdr <> encoded_elem
    end)
  end

  # decodes each element of a binary
  defp xdr_to_array(xdr, type, array_length) do
    decoded = case function_exported?(type, :length, 0) do
      true -> decode_fixed_type(xdr, type, array_length, [])
      false -> decode_variable_type(xdr, type, array_length, [])
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
    <<elem_length :: big-unsigned-integer-size(32), rest :: binary>> = xdr
    <<elem :: bits-size(elem_length), _padding :: binary>> = rest

    case type.decode(elem) do
      {:ok, val} -> decode_variable_type(rest, type, array_length - 1, [val | array])
      {:error, reason} -> reason
    end
  end
end