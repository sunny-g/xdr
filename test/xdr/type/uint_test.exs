defmodule XDR.Type.UintTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.Uint

  @min_uint 0
  @max_uint Math.pow(2, 32) - 1

  test "new" do
    assert Uint.new === {:ok, 0}
    assert Uint.new(@min_uint) === {:ok, @min_uint}
    assert Uint.new(@max_uint) === {:ok, @max_uint}

    assert Uint.new(@min_uint - 1) === {:error, :invalid}
    assert Uint.new(@max_uint + 1) === {:error, :invalid}
    assert Uint.new(<<1>>) === {:error, :invalid}
    assert Uint.new("1") === {:error, :invalid}
    assert Uint.new(nil) === {:error, :invalid}
    assert Uint.new(false) === {:error, :invalid}
  end

  test "valid?" do
    assert Uint.valid?(1) == true
    assert Uint.valid?(@min_uint) == true
    assert Uint.valid?(@max_uint) == true

    assert Uint.valid?(-1) == false
    assert Uint.valid?(0.0) == false
    assert Uint.valid?(-0.1) == false
    assert Uint.valid?(:math.pow(2, 32) - 1) == false
    assert Uint.valid?(@min_uint - 1) == false
    assert Uint.valid?(@max_uint + 1) == false
    assert Uint.valid?(true) == false
    assert Uint.valid?(false) == false
    assert Uint.valid?(nil) == false
    assert Uint.valid?("0") == false
    assert Uint.valid?({}) == false
    assert Uint.valid?([]) == false
    assert Uint.valid?([0]) == false
  end

  test "encode" do
    assert Uint.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert Uint.encode(@min_uint) == {:ok, <<0, 0, 0, 0>>}
    assert Uint.encode(@max_uint) == {:ok, <<255, 255, 255, 255>>}

    assert Uint.encode(0.1) == {:error, :invalid}
    assert Uint.encode(@min_uint - 1) == {:error, :out_of_bounds}
    assert Uint.encode(@max_uint + 1) == {:error, :out_of_bounds}
  end

  test "decode" do
    assert Uint.decode(<<0, 0, 0, 1>>) == {:ok, 1}
    assert Uint.decode(<<0, 0, 0, 0>>) == {:ok, @min_uint}
    assert Uint.decode(<<255, 255, 255, 255>>) == {:ok, @max_uint}

    assert Uint.decode("0") == {:error, :invalid}
    assert Uint.decode(<<0, 0, 0, 0, 0>>) == {:error, :invalid}
    assert Uint.decode(<<127, 255, 255, 255, 255>>) == {:error, :invalid}
  end
end
