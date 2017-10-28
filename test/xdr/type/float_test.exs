defmodule XDR.Type.FloatTest do
  use ExUnit.Case
  alias XDR.Type.Float

  test "length" do
    assert Float.length === 32
  end

  test "new" do
    assert Float.new === {:ok, 0.0}
    assert Float.new(0) === {:ok, 0}
    assert Float.new(0.0) === {:ok, 0.0}
    assert Float.new(1.0) === {:ok, 1.0}
    assert Float.new(-1.0) === {:ok, -1.0}

    assert Float.new(<<0>>) === {:error, :invalid}
    assert Float.new("0") === {:error, :invalid}
    assert Float.new("0.0") === {:error, :invalid}
    assert Float.new(false) === {:error, :invalid}
    assert Float.new(nil) === {:error, :invalid}
    assert Float.new([]) === {:error, :invalid}
    assert Float.new({}) === {:error, :invalid}
  end

  test "valid?" do
    assert Float.valid?(0) == true
    assert Float.valid?(-1) == true
    assert Float.valid?(1.0) == true
    assert Float.valid?(100000.0) == true

    assert Float.valid?(:infinity) == false
    assert Float.valid?(nil) == false
  end

  test "encode" do
    assert Float.encode(0) == {:ok, <<0, 0, 0, 0>>}
    assert Float.encode(0.0) == {:ok, <<0, 0, 0, 0>>}
    assert Float.encode(-0.0) == {:ok, <<0, 0, 0, 0>>}
    assert Float.encode(1) == {:ok, <<63, 128, 0, 0>>}
    assert Float.encode(1.0) == {:ok, <<63, 128, 0, 0>>}
    assert Float.encode(-1.0) == {:ok, <<191, 128, 0, 0>>}
  end

  test "decode" do
    assert Float.decode(<<0, 0, 0, 0>>) == {:ok, 0.0}
    assert Float.decode(<<0, 0, 0, 0>>) == {:ok, -0.0}
    assert Float.decode(<<128, 0, 0, 0>>) == {:ok, -0.0}
    assert Float.decode(<<63, 128, 0, 0>>) == {:ok, 1.0}
    assert Float.decode(<<191, 128, 0, 0>>) == {:ok, -1.0}

    assert Float.decode(<<127, 192, 0, 0>>) == {:error, :invalid}
    assert Float.decode(<<127, 248, 0, 0>>) == {:error, :invalid}
  end
end
