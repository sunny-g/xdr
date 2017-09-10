defmodule XDR.Type.Base do
  @type t :: any
  @type xdr :: <<_::_*32>>

  @doc """
  Returns the expected length (in bits) of a XDR-encoded binary of this type (sans padding)
  """
  @callback length :: non_neg_integer

  @doc """
  Determines if a value is a valid XDR type
  """
  @callback is_valid?(any) :: boolean

  @doc """
  Encodes a native type to an XDR binary
  """
  @callback encode(native :: __MODULE__.t) :: {:ok, xdr :: __MODULE__.xdr} | {:error, reason :: atom}

  @doc """
  Decodes an XDR binary to a native type
  """
  @callback decode(xdr :: __MODULE__.xdr) :: {:ok, native :: __MODULE__.t} | {:error, reason :: atom}
end