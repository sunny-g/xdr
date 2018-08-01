defmodule XDR.Util.Macros do
  @moduledoc """
  XDR Macros (to be used in guard clauses)
  """

  defguard is_valid_xdr(binary)
           when is_binary(binary) and rem(byte_size(binary), 4) === 0

  defguard calculate_padding(len)
           when rem(len, 4)

  defguard required_padding(binary)
           when 4 - rem(byte_size(binary), 4)
end

defmodule XDR.Util do
  @moduledoc false

  require XDR.Util.Macros

  def required_padding(len) when XDR.Util.Macros.calculate_padding(len) == 0, do: 0

  def required_padding(len) when is_integer(len) do
    4 - XDR.Util.Macros.calculate_padding(len)
  end

  @doc """
  Determines if the module is a valid XDR Type module (as defined by it's exported functions)
  """
  def valid_xdr_type?(atom) when is_atom(atom) do
    function_exported?(atom, :length, 0) and
      (function_exported?(atom, :new, 0) or function_exported?(atom, :new, 1)) and
      function_exported?(atom, :valid?, 1) and function_exported?(atom, :encode, 1) and
      function_exported?(atom, :decode, 1)
  end

  def valid_xdr_type?(_), do: false
end
