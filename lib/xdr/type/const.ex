defmodule XDR.Type.Const do
  @moduledoc """
  RFC 4506, Section 4.17 - Const
  """

  defmacro __using__(opts) do
    const = Keyword.get(opts, :value)

    module =
      opts
      |> Keyword.get(:type)
      |> Macro.expand(__ENV__)

    module_name = Atom.to_string(module)

    if not module.valid?(const) do
      raise "invalid Const module spec: #{const} is not a valid #{module_name}"
    end

    {:ok, const_xdr} = module.encode(const)

    quote do
      @behaviour XDR.Type.Base

      defdelegate length, to: unquote(module)

      def new(val \\ unquote(const))
      def new(val) when val === unquote(const), do: {:ok, val}
      def new(_), do: {:error, :invalid}

      def valid?(val), do: val === unquote(const)

      def encode(unquote(const)), do: {:ok, unquote(const_xdr)}
      def encode(_), do: {:error, :invalid_const}

      def decode(<<unquote(const_xdr), rest::binary>>), do: {:ok, {unquote(const), rest}}
      def decode(_), do: {:error, :invalid_const}
    end
  end
end
