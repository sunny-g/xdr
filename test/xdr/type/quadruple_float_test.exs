defmodule XDR.Type.QuadrupleFloatTest do
  use ExUnit.Case
  alias XDR.Type.QuadrupleFloat

  test "valid?" do
    assert QuadrupleFloat.valid?(0.0) == false
  end

  test "encode" do
    assert QuadrupleFloat.encode(0.0) == {:error, :not_implemented}
  end

  test "decode" do
    assert QuadrupleFloat.encode(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == {:error, :not_implemented}
  end
end
