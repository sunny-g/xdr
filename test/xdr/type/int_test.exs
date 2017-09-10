defmodule XDR.Type.IntTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.Int
  doctest XDR.Type.Int

  @min_int -Math.pow(2, 31)
  @max_int Math.pow(2, 31) - 1

  test "is_valid?" do
    assert Int.is_valid?(0) == true
    assert Int.is_valid?(1) == true
    assert Int.is_valid?(-1) == true
    assert Int.is_valid?(@min_int) == true
    assert Int.is_valid?(@max_int) == true

    assert Int.is_valid?(0.0) == false
    assert Int.is_valid?(-0.1) == false
    assert Int.is_valid?(-:math.pow(2, 31)) == false
    assert Int.is_valid?(:math.pow(2, 31) - 1) == false
    assert Int.is_valid?(@min_int - 1) == false
    assert Int.is_valid?(@max_int + 1) == false
    assert Int.is_valid?(true) == false
    assert Int.is_valid?(false) == false
    assert Int.is_valid?(nil) == false
    assert Int.is_valid?("0") == false
    assert Int.is_valid?({}) == false
    assert Int.is_valid?([]) == false
    assert Int.is_valid?([0]) == false
  end

  test "encode" do
    assert Int.encode(0) == {:ok, <<0, 0, 0, 0>>}
    assert Int.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert Int.encode(-1) == {:ok, <<255, 255, 255, 255>>}
    assert Int.encode(@min_int) == {:ok, <<128, 0, 0, 0>>}
    assert Int.encode(@max_int) == {:ok, <<127, 255, 255, 255>>}

    assert Int.encode(0.1) == {:error, :invalid}
    assert Int.encode(@min_int - 1) == {:error, :out_of_bounds}
    assert Int.encode(@max_int + 1) == {:error, :out_of_bounds}
  end

  test "decode" do
    assert Int.decode(<<0, 0, 0, 0>>) == {:ok, 0}
    assert Int.decode(<<0, 0, 0, 1>>) == {:ok, 1}
    assert Int.decode(<<255, 255, 255, 255>>) == {:ok, -1}
    assert Int.decode(<<128, 0, 0, 0>>) == {:ok, @min_int}
    assert Int.decode(<<127, 255, 255, 255>>) == {:ok, @max_int}

    assert Int.decode("0") == {:error, :invalid}
    assert Int.decode(<<0, 0, 0, 0, 0>>) == {:error, :invalid}
    assert Int.decode(<<127, 255, 255, 255, 255>>) == {:error, :invalid}
  end
end
