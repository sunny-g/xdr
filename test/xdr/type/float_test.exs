defmodule XDR.Type.FloatTest do
  use ExUnit.Case
  alias XDR.Type.Float
  doctest XDR.Type.Float

  test "is_valid?" do
    assert Float.is_valid?(0) == true
    assert Float.is_valid?(-1) == true
    assert Float.is_valid?(1.0) == true
    assert Float.is_valid?(100000.0) == true

    assert Float.is_valid?(:infinity) == false
    assert Float.is_valid?(nil) == false
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
