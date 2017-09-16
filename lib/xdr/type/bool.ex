defmodule XDR.Type.Bool do
  use XDR.Type.Enum, spec: [false: 0, true: 1]
end
