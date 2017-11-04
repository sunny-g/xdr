defmodule XDR.Type.Base do
  @moduledoc """
  Base behaviour for XDR type modules
  """

  @type t :: any
  @type xdr :: <<_ :: _ * 32>>
  @type error :: atom | String.t

  @doc """
  Returns the expected length (in bytes) of an XDR-encoded binary of this type (sans padding)
  """
  @callback length :: non_neg_integer | :struct | :union | :variable

  @doc """
  Returns the input if it's a valid XDR module native type, or the default valid native type
  """
  @callback new(native :: t) :: {:ok, native :: t} | {:error, reason :: error}

  @doc """
  Determines if a value is a valid XDR type
  """
  @callback valid?(native :: t) :: boolean

  @doc """
  Encodes a native type to an XDR binary
  """
  @callback encode(native :: t) :: {:ok, xdr :: xdr} | {:error, reason :: error}

  @doc """
  Decodes an XDR binary to a native type, also returns any un-decoded binary
  """
  @callback decode(xdr :: xdr) :: {:ok, {native :: t, rest :: xdr}} | {:error, reason :: error}

  @optional_callbacks [length: 1, new: 0]
end
