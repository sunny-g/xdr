defmodule XDR.Type.Optional do
  alias XDR.Type.Bool
  alias XDR.Type.Union
  alias XDR.Type.Void

  defmacro __using__(for: for) do
    quote do
      @behaviour XDR.Type.Base

      @type t :: nil | any
      @type for :: module
      @type xdr :: <<_ :: 32>>

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

      def length, do: :variable

      @spec new(val :: t) :: {:ok, val :: t} | {:error, reason :: atom}
      def new(nil), do: {:ok, nil}
      def new(val) do
        case super({true, val}) do
          {:ok, {true, val}} ->
            {:ok, val}
          {:error, reason} ->
            {:error, reason}
        end
      end

      @spec valid?(val :: t) :: boolean
      def valid?(nil), do: super(false)
      def valid?(val), do: super({true, val})

      @spec encode(val :: t) :: {:ok, xdr :: xdr} | {:error, reason :: atom}
      def encode(nil), do: super(false)
      def encode(val), do: super({true, val})

      @spec decode(xdr :: xdr) :: {:ok, val :: t} | {:error, reason :: atom}
      def decode(xdr) do
        case super(xdr) do
          {:ok, {false, rest}} ->
            {:ok, {nil, rest}}
          {:ok, {{true, val}, rest}} ->
            {:ok, {val, rest}}
          {:error, reason} ->
            {:error, reason}
        end
      end

      defoverridable [length: 0, new: 1, valid?: 1, encode: 1, decode: 1]
    end
  end
end
