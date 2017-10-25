defmodule XDR.Type.Bool do
  alias XDR.Type.Enum

  @type t :: boolean
  @type xdr :: Enum.xdr

  use Enum, spec: [false: 0, true: 1]
end
