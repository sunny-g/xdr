defmodule XDR.Type.Bool do
  @moduledoc """
  RFC 4506, Section 4.4 - Boolean
  """

  @type t :: boolean
  @type xdr :: Enum.xdr()

  use XDR.Type.Enum,
    false: 0,
    true: 1
end
