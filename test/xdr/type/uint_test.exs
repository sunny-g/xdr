defmodule XDR.Type.UintTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.Uint
  doctest XDR.Type.Uint

  @min_uint 0
  @max_uint Math.pow(2, 32) - 1

  test "is_valid?" do
    assert Uint.is_valid?(1) == true
    assert Uint.is_valid?(@min_uint) == true
    assert Uint.is_valid?(@max_uint) == true

    assert Uint.is_valid?(-1) == false
    assert Uint.is_valid?(0.0) == false
    assert Uint.is_valid?(-0.1) == false
    assert Uint.is_valid?(:math.pow(2, 32) - 1) == false
    assert Uint.is_valid?(@min_uint - 1) == false
    assert Uint.is_valid?(@max_uint + 1) == false
    assert Uint.is_valid?(true) == false
    assert Uint.is_valid?(false) == false
    assert Uint.is_valid?(nil) == false
    assert Uint.is_valid?("0") == false
    assert Uint.is_valid?({}) == false
    assert Uint.is_valid?([]) == false
    assert Uint.is_valid?([0]) == false
  end

  test "encode" do
    assert Uint.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert @min_uint |> Uint.encode == {:ok, <<0, 0, 0, 0>>}
    assert @max_uint |> Uint.encode == {:ok, <<255, 255, 255, 255>>}

    assert Uint.encode(0.1) == {:error, :invalid}
    assert Uint.encode(@min_uint - 1) == {:error, :out_of_bounds}
    assert Uint.encode(@max_uint + 1) == {:error, :out_of_bounds}

  end

  test "decode" do
    assert Uint.decode(<<0, 0, 0, 1>>) == {:ok, 1}
    assert Uint.decode(<<0, 0, 0, 0>>) == {:ok, @min_uint}
    assert Uint.decode(<<255, 255, 255, 255>>) == {:ok, @max_uint}
  end
end
