defmodule XDR.Util.Delegate do
  @moduledoc """
  Module to be `use`d for aliasing an XDR Type module
  """

  defmacro __using__(to: to_module) do
    required = quote do: require(unquote(to_module))

    quote do
      unless unquote(__MODULE__).valid_xdr_type?(unquote(to_module)) do
        raise "can only delegate to valid XDR Type modules"
      end

      unquote(required)

      @behaviour XDR.Type.Base

      defdelegate length, to: unquote(to_module)
      defdelegate valid?(native), to: unquote(to_module)
      defdelegate encode(native), to: unquote(to_module)
      defdelegate decode(native), to: unquote(to_module)

      if function_exported?(unquote(to_module), :new, 0) do
        defdelegate new, to: unquote(to_module)
        defdelegate new(native), to: unquote(to_module)
      else
        defdelegate new(native), to: unquote(to_module)
      end
    end
  end

  @doc """
  Determines if the module is a valid XDR Type module (as defined by it's exported functions)
  """
  def valid_xdr_type?(module) when is_atom(module) do
    function_exported?(module, :length, 0) and
      (function_exported?(module, :new, 0) or function_exported?(module, :new, 1)) and
      function_exported?(module, :valid?, 1) and function_exported?(module, :encode, 1) and
      function_exported?(module, :decode, 1)
  end

  def valid_xdr_type?(_), do: false
end

defmodule XDR.Util.Guards do
  @moduledoc """
  XDR Guards
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

  require XDR.Util.Guards

  defdelegate valid_xdr_type?(module), to: XDR.Util.Delegate

  def required_padding(len) when XDR.Util.Guards.calculate_padding(len) == 0, do: 0

  def required_padding(len) when is_integer(len) do
    4 - XDR.Util.Guards.calculate_padding(len)
  end
end
