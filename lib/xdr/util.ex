defmodule XDR.Util.Macros do
  defmacro is_valid_xdr?(binary) do
    quote do
      is_binary(unquote(binary)) and required_padding(unquote(binary)) === 4
    end
  end

  defmacro required_padding(binary) do
    quote do
      4 - rem(byte_size(unquote(binary)), 4)
    end
  end
end

defmodule XDR.Util do
  import XDR.Util.Macros

  @doc """
  Calculates the padding required to pad to a multiple of 4
  """
  @spec calculate_padding(binary | non_neg_integer) :: non_neg_integer
  def calculate_padding(binary) when is_binary(binary), do: required_padding(binary)

  @doc """
  Determines
  """
  def is_xdr_type_module(atom) when is_atom(atom) do
    function_exported?(atom, :length, 0)
    and (function_exported?(atom, :new, 1) or function_exported?(atom, :new, 0))
    and function_exported?(atom, :valid?, 1)
    and function_exported?(atom, :encode, 1)
    and function_exported?(atom, :decode, 1)
  end
  def is_xdr_type_module(_), do: false
end
