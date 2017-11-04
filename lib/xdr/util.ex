defmodule XDR.Util.Macros do
  @moduledoc """
  XDR Macros (to be used in guard clauses)
  """

  defmacro is_valid_xdr?(binary) do
    quote do
      is_binary(unquote(binary)) and calculate_padding(byte_size(unquote(binary))) === 0
    end
  end

  defmacro calculate_padding(len) do
    quote do: rem(unquote(len), 4)
  end

  defmacro required_padding(binary) do
    quote do: 4 - calculate_padding(byte_size(unquote(binary)))
  end
end

defmodule XDR.Util do
  @moduledoc false

  require XDR.Util.Macros

  def required_padding(0), do: 0
  def required_padding(4), do: 0
  def required_padding(len) when is_integer(len) do
    4 - XDR.Util.Macros.calculate_padding(len)
  end

  @doc """
  Determines if the module is a valid XDR Type module (as defined by it's exported functions)
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
