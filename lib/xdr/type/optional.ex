defmodule XDR.Type.Optional do
  @moduledoc """
  RFC 4506, Section 4.19 - Optional data
  """

  alias XDR.Type.{
    Base,
    Bool,
    Union,
    Void
  }

  defmacro __using__(for: optional_type) do
    quote do
      @behaviour XDR.Type.Base

      @type t :: nil | unquote(optional_type).t()
      @type type :: module
      @type xdr :: Base.xdr()

      use Union,
        switch: Bool,
        cases: [
          true: :type,
          false: Void
        ],
        attributes: [
          type: unquote(optional_type)
        ]

      def length, do: :variable

      @spec new(val :: t) :: {:ok, val :: t} | {:error, reason :: Base.error()}
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

      @spec encode(val :: t) :: {:ok, xdr :: xdr} | {:error, reason :: Base.error()}
      def encode(nil), do: super(false)
      def encode(val), do: super({true, val})

      @spec decode(xdr :: xdr) :: {:ok, {val :: t, rest :: Base.xdr()}} | {:error, reason :: atom}
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

      defoverridable length: 0, new: 1, valid?: 1, encode: 1, decode: 1
    end
  end
end
