defmodule XDR.Type.DoubleFloatTest do
  use ExUnit.Case
  alias XDR.Type.DoubleFloat

  test "length" do
    assert DoubleFloat.length === 64
  end

  test "new" do
    assert DoubleFloat.new === {:ok, 0.0}
    assert DoubleFloat.new(0) === {:ok, 0}
    assert DoubleFloat.new(0.0) === {:ok, 0.0}
    assert DoubleFloat.new(1.0) === {:ok, 1.0}
    assert DoubleFloat.new(-1.0) === {:ok, -1.0}

    assert DoubleFloat.new(<<0>>) === {:error, :invalid}
    assert DoubleFloat.new("0") === {:error, :invalid}
    assert DoubleFloat.new("0.0") === {:error, :invalid}
    assert DoubleFloat.new(false) === {:error, :invalid}
    assert DoubleFloat.new(nil) === {:error, :invalid}
    assert DoubleFloat.new([]) === {:error, :invalid}
    assert DoubleFloat.new({}) === {:error, :invalid}
  end

  test "valid?" do
    assert DoubleFloat.valid?(0) == true
    assert DoubleFloat.valid?(-1) == true
    assert DoubleFloat.valid?(1.0) == true
    assert DoubleFloat.valid?(100000000.0) == true

    assert DoubleFloat.valid?(:infinity) == false
    assert DoubleFloat.valid?(nil) == false
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
