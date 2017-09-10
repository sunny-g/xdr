defmodule XDR.Type.FixedOpaque.Validation do
  defmacro is_valid_fixed_opaque?(opaque, len) do
    quote do
      is_binary(unquote(opaque))
      and is_integer(unquote(len))
      and byte_size(unquote(opaque)) === unquote(len)
    end
  end
end

defmodule XDR.Type.FixedOpaque do
  import XDR.Util.Macros
  import XDR.Type.FixedOpaque.Validation

  @type t :: binary
  @type xdr :: <<_ :: _*32>>

  @doc """
  """
  @spec is_valid?(any, len :: non_neg_integer) :: boolean
  def is_valid?(opaque, len), do: is_valid_fixed_opaque?(opaque, len)

  @doc """
  """
  @spec encode(opaque :: __MODULE__.t, len :: non_neg_integer) :: {:ok, xdr :: __MODULE__.xdr} | {:error, :invalid}
  def encode(opaque, len) when not is_valid_fixed_opaque?(opaque, len), do: {:error, :invalid}
  def encode(opaque, _) when required_padding(opaque) === 0, do: {:ok, opaque}
  def encode(opaque, _) when required_padding(opaque) === 1, do: {:ok, opaque <> <<0>>}
  def encode(opaque, _) when required_padding(opaque) === 2, do: {:ok, opaque <> <<0, 0>>}
  def encode(opaque, _) when required_padding(opaque) === 3, do: {:ok, opaque <> <<0, 0, 0>>}

  @doc """
  """
  @spec decode(xdr :: __MODULE__.xdr, len :: non_neg_integer) :: {:ok, opaque :: __MODULE__.t} | {:error, :invalid | :out_of_bounds}
  def decode(xdr, _) when not is_valid_xdr?(xdr), do: {:error, :invalid}
  def decode(xdr, len) when len > byte_size(xdr), do: {:error, :out_of_bounds}
  def decode(xdr, len) do
    <<opaque :: binary-size(len), _ :: binary>> = xdr
    {:ok, opaque}
  end
end
