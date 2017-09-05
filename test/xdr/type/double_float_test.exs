defmodule XDR.Type.DoubleFloatTest do
  use ExUnit.Case
  alias XDR.Type.DoubleFloat
  doctest XDR.Type.DoubleFloat

  test "is_valid?" do
    assert DoubleFloat.is_valid?(0) == true
    assert DoubleFloat.is_valid?(-1) == true
    assert DoubleFloat.is_valid?(1.0) == true
    assert DoubleFloat.is_valid?(100000000.0) == true

    assert DoubleFloat.is_valid?(:infinity) == false
    assert DoubleFloat.is_valid?(nil) == false
  end

  test "encode" do
    assert DoubleFloat.encode(0) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert DoubleFloat.encode(0.0) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert DoubleFloat.encode(-0.0) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert DoubleFloat.encode(1) == {:ok, <<63, 240, 0, 0, 0, 0, 0, 0>>}
    assert DoubleFloat.encode(1.0) == {:ok, <<63, 240, 0, 0, 0, 0, 0, 0>>}
    assert DoubleFloat.encode(-1.0) == {:ok, <<191, 240, 0, 0, 0, 0, 0, 0>>}
  end

  test "decode" do
    assert DoubleFloat.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, 0.0}
    assert DoubleFloat.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, -0.0}
    assert DoubleFloat.decode(<<128, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, -0.0}
    assert DoubleFloat.decode(<<63, 240, 0, 0, 0, 0, 0, 0>>) == {:ok, 1.0}
    assert DoubleFloat.decode(<<191, 240, 0, 0, 0, 0, 0, 0>>) == {:ok, -1.0}

    assert DoubleFloat.decode(<<127, 240, 0, 0, 0, 0, 0, 0>>) == {:error, :invalid}
    assert DoubleFloat.decode(<<127, 248, 0, 0, 0, 0, 0, 0>>) == {:error, :invalid}
  end
end
