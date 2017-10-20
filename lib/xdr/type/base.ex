defmodule XDR.Type.Base do
  @type t :: any
  @type xdr :: <<_::_*32>>
  @type error :: atom | String.t

  @doc """
  Returns the expected length (in bits) of an XDR-encoded binary of this type (sans padding)
  """
  @callback length :: non_neg_integer

  @doc """
  Returns the input if it's a valid XDR module native type, or a default valid native type
  """
  @callback new(any) :: {:ok, native :: t} | {:error, reason :: error}

  @doc """
  Determines if a value is a valid XDR type
  """
  @callback valid?(any) :: boolean

  @doc """
  Encodes a native type to an XDR binary
  """
  @callback encode(native :: t) :: {:ok, xdr :: xdr} | {:error, reason :: error}

  @doc """
  Decodes an XDR binary to a native type
  """
  @callback decode(xdr :: xdr) :: {:ok, native :: t} | {:error, reason :: error}

  @optional_callbacks new: 0
end
