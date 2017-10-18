defmodule XDR.Type.Const do
  defmacro __using__(opts) do
    const = Keyword.get(opts, :value)
    module = Keyword.get(opts, :type) |> Macro.expand(__ENV__)
    module_name = Atom.to_string(module)

    if not module.valid?(const) do
      raise "invalid Const spec: #{const} is not a valid #{module_name}"
    end

    {:ok, const_xdr} = module.encode(const)

    quote do
      @behaviour XDR.Type.Base

      defdelegate length, to: unquote(module)
      def valid?(val), do: val === unquote(const)

      def encode(unquote(const)), do: {:ok, unquote(const_xdr)}
      def encode(_), do: {:error, :invalid_const}

      def decode(unquote(const_xdr)), do: {:ok, unquote(const)}
      def decode(_), do: {:error, :invalid_const}
    end
  end
end
