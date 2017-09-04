defmodule XDR.Type.IntTest do
  use ExUnit.Case
  require Math
  import XDR.Type.Int.Validation
  alias XDR.Type.Int
  doctest XDR.Type.Int

  @min_int -Math.pow(2, 31)
  @max_int Math.pow(2, 31) - 1

  test "is_valid?" do
    assert is_valid?(0) == true
    assert is_valid?(1) == true
    assert is_valid?(-1) == true
    assert is_valid?(@min_int) == true
    assert is_valid?(@max_int) == true

    assert is_valid?(0.0) == false
    assert is_valid?(-0.1) == false
    assert is_valid?(-:math.pow(2, 31)) == false
    assert is_valid?(:math.pow(2, 31) - 1) == false
    assert is_valid?(@min_int - 1) == false
    assert is_valid?(@max_int + 1) == false
    assert is_valid?(true) == false
    assert is_valid?(false) == false
    assert is_valid?(nil) == false
    assert is_valid?("0") == false
    assert is_valid?({}) == false
    assert is_valid?([]) == false
    assert is_valid?([0]) == false
  end

  test "encode" do
    assert Int.encode(0) == {:ok, <<0, 0, 0, 0>>}
    assert Int.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert Int.encode(-1) == {:ok, <<255, 255, 255, 255>>}
    assert @min_int |> Int.encode == {:ok, <<128, 0, 0, 0>>}
    assert @max_int |> Int.encode == {:ok, <<127, 255, 255, 255>>}

    assert Int.encode(0.1) == {:error, :invalid}
    assert @min_int - 1 |> Int.encode == {:error, :out_of_bounds}
    assert @max_int + 1 |> Int.encode == {:error, :out_of_bounds}
  end

  test "decode" do
    assert Int.decode(<<0, 0, 0, 0>>) == {:ok, 0}
    assert Int.decode(<<0, 0, 0, 1>>) == {:ok, 1}
    assert Int.decode(<<255, 255, 255, 255>>) == {:ok, -1}
    assert Int.decode(<<128, 0, 0, 0>>) == {:ok, @min_int}
    assert Int.decode(<<127, 255, 255, 255>>) == {:ok, @max_int}

    assert Int.decode("0") == {:error, :invalid}
    assert Int.decode(<<0, 0, 0, 0, 0>>) == {:error, :out_of_bounds}
    assert Int.decode(<<127, 255, 255, 255, 255>>) == {:error, :out_of_bounds}
  end
end
