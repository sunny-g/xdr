defmodule XDR.Type.QuadrupleFloatTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias XDR.Type.QuadrupleFloat

  test "valid?" do
    assert QuadrupleFloat.valid?(0.0) == false
  end

  test "encode" do
    assert QuadrupleFloat.encode(0.0) == {:error, :not_implemented}
  end

  test "decode" do
    assert QuadrupleFloat.encode(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) ==
             {:error, :not_implemented}
  end
end
