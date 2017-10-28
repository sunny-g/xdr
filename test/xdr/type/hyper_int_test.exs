defmodule XDR.Type.HyperIntTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.HyperInt

  @min_hyper_int -Math.pow(2, 63)
  @max_hyper_int Math.pow(2, 63) - 1

  test "length" do
    assert HyperInt.length === 64
  end

  test "new" do
    assert HyperInt.new === {:ok, 0}
    assert HyperInt.new(0) === {:ok, 0}
    assert HyperInt.new(1) === {:ok, 1}
    assert HyperInt.new(@min_hyper_int) === {:ok, @min_hyper_int}
    assert HyperInt.new(@max_hyper_int) === {:ok, @max_hyper_int}

    assert HyperInt.new(@min_hyper_int - 1) === {:error, :invalid}
    assert HyperInt.new(@max_hyper_int + 1) === {:error, :invalid}
    assert HyperInt.new("0") === {:error, :invalid}
    assert HyperInt.new(nil) === {:error, :invalid}
    assert HyperInt.new(false) === {:error, :invalid}
    assert HyperInt.new([]) === {:error, :invalid}
    assert HyperInt.new({}) === {:error, :invalid}
  end

  test "valid?" do
    assert HyperInt.valid?(0) == true
    assert HyperInt.valid?(1) == true
    assert HyperInt.valid?(-1) == true
    assert HyperInt.valid?(@min_hyper_int) == true
    assert HyperInt.valid?(@max_hyper_int) == true

    assert HyperInt.valid?(0.0) == false
    assert HyperInt.valid?(-0.1) == false
    assert HyperInt.valid?(-:math.pow(2, 63)) == false
    assert HyperInt.valid?(:math.pow(2, 63) - 1) == false
    assert HyperInt.valid?(@min_hyper_int - 1) == false
    assert HyperInt.valid?(@max_hyper_int + 1) == false
    assert HyperInt.valid?(true) == false
    assert HyperInt.valid?(false) == false
    assert HyperInt.valid?(nil) == false
    assert HyperInt.valid?("0") == false
    assert HyperInt.valid?({}) == false
    assert HyperInt.valid?([]) == false
    assert HyperInt.valid?([0]) == false
  end

  test "encode" do
    assert HyperInt.encode(0) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert HyperInt.encode(1) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 1>>}
    assert HyperInt.encode(-1) == {:ok, <<255, 255, 255, 255, 255, 255, 255, 255>>}
    assert HyperInt.encode(@min_hyper_int) == {:ok, <<128, 0, 0, 0, 0, 0, 0, 0>>}
    assert HyperInt.encode(@max_hyper_int) == {:ok, <<127, 255, 255, 255, 255, 255, 255, 255>>}

    assert HyperInt.encode(0.1) == {:error, :invalid}
    assert HyperInt.encode(@min_hyper_int - 1) == {:error, :out_of_bounds}
    assert HyperInt.encode(@max_hyper_int + 1) == {:error, :out_of_bounds}
  end

  test "decode" do
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, 0}
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 1}
    assert HyperInt.decode(<<255, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, -1}
    assert HyperInt.decode(<<128, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, @min_hyper_int}
    assert HyperInt.decode(<<127, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, @max_hyper_int}

    assert HyperInt.decode("0") == {:error, :invalid}
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 0, 0>>) == {:error, :invalid}
    assert HyperInt.decode(<<127, 255, 255, 255, 255, 255, 255, 255, 255>>) == {:error, :invalid}
  end
end
