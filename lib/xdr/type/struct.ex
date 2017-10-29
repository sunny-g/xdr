defmodule XDR.Type.Struct do
  require OK

  defmacro __using__(spec: spec) do
    keys = Keyword.keys(spec)

    quote do
      @behaviour XDR.Type.Base

      import XDR.Util.Macros

      defstruct unquote(keys)

      @type t :: struct
      @type spec :: keyword(xdr_module :: module)
      @type xdr :: <<_ :: 32>>

      def length, do: :struct

      @spec new(val :: t) :: {:ok, val :: t} | {:error, reason :: :invalid}
      def new(val), do: new(val, unquote(spec))

      @spec valid?(val :: t) :: boolean
      def valid?(val), do: valid?(val, unquote(spec))

      @spec encode(val :: t) :: {:ok, xdr :: xdr} | {:error, reason :: :invalid}
      def encode(val), do: encode(val, unquote(spec))

      @spec decode(xdr :: xdr) :: {:ok, val :: t} | {:error, reason :: :invalid}
      def decode(xdr), do: decode(xdr, unquote(spec))

      #-----------------------------------------------------------------------#
      # PRIVATE IMPLEMENTATIONS
      #-----------------------------------------------------------------------#

      @doc false
      defp new(%__MODULE__{} = struct, spec) do
        if valid?(struct, spec), do: {:ok, struct}, else: {:error, :invalid}
      end
      defp new(_, spec), do: {:error, :invalid}

      @doc false
      defp valid?(%__MODULE__{} = struct, spec) do
        Enum.all?(spec, &unquote(__MODULE__).valid?(struct, &1))
      end
      defp valid?(_, spec), do: false

      @doc false
      defp encode(%__MODULE__{} = struct, spec) do
        res = {:ok, <<>>}
        Enum.reduce(spec, res, &unquote(__MODULE__).encode(struct, &1, &2))
      end
      defp encode(_, spec), do: {:error, :invalid}

      @doc false
      defp decode(xdr, spec) when not is_valid_xdr?(xdr), do: {:error, :invalid}
      defp decode(xdr, spec) do
        res = {:ok, {%__MODULE__{}, xdr}}
        Enum.reduce(spec, res, &unquote(__MODULE__).decode(&1, &2))
      end
    end
  end

  #---------------------------------------------------------------------------#
  # HELPERS
  #---------------------------------------------------------------------------#

  def valid?(struct, {key, module}), do: Map.get(struct, key) |> module.valid?

  def encode(_struct, {_, _}, {:error, reason}), do: {:error, reason}
  def encode(struct, {key, module}, {:ok, curr_xdr}) do
    OK.with do
      xdr <- Map.get(struct, key) |> module.encode
      {:ok, curr_xdr <> xdr}
    end
  end

  def decode({_, _}, {:error, reason}), do: {:error, reason}
  def decode({key, module}, {:ok, {struct, xdr}}) do
    OK.with do
      {val, rest} <- module.decode(xdr)
      {:ok, {Map.put(struct, key, val), rest}}
    end
  end
end
