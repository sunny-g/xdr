defmodule XDR.Type.Bool do
  @type t :: boolean

  use XDR.Type.Enum, spec: [false: 0, true: 1]
end
