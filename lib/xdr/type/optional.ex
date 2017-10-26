defmodule XDR.Type.Optional do
  alias XDR.Type.Bool
  alias XDR.Type.Union
  alias XDR.Type.Void

  defmacro __using__(for: for) do
    quote do
      @behaviour XDR.Type.Base

      use Union, spec: [
        switch: Bool,
        cases: [
          true:   :type,
          false:  Void,
        ],
        attributes: [
          type:   unquote(for),
        ],
      ]

      def length, do: 32

      def new(nil), do: {:ok, nil}
      def new(val) do
        case super({true, val}) do
          {:ok, {true, val}} ->
            {:ok, val}
          {:error, reason} ->
            {:error, reason}
        end
      end

      def valid?(nil), do: super(false)
      def valid?(val), do: super({true, val})

      def encode(nil), do: super(false)
      def encode(val), do: super({true, val})

      def decode(xdr) do
        case super(xdr) do
          {:ok, false} ->
            {:ok, nil}
          {:ok, {true, val}} ->
            {:ok, val}
          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end
end
