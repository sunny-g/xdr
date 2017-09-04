defmodule XDR.Type.HyperIntTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.HyperInt
  doctest XDR.Type.HyperInt

  @min_hyper_int -Math.pow(2, 63)
  @max_hyper_int Math.pow(2, 63) - 1

  test "is_valid?" do
    assert HyperInt.is_valid?(0) == true
    assert HyperInt.is_valid?(1) == true
    assert HyperInt.is_valid?(-1) == true
    assert HyperInt.is_valid?(@min_hyper_int) == true
    assert HyperInt.is_valid?(@max_hyper_int) == true

    assert HyperInt.is_valid?(0.0) == false
    assert HyperInt.is_valid?(-0.1) == false
    assert HyperInt.is_valid?(-:math.pow(2, 63)) == false
    assert HyperInt.is_valid?(:math.pow(2, 63) - 1) == false
    assert HyperInt.is_valid?(@min_hyper_int - 1) == false
    assert HyperInt.is_valid?(@max_hyper_int + 1) == false
    assert HyperInt.is_valid?(true) == false
    assert HyperInt.is_valid?(false) == false
    assert HyperInt.is_valid?(nil) == false
    assert HyperInt.is_valid?("0") == false
    assert HyperInt.is_valid?({}) == false
    assert HyperInt.is_valid?([]) == false
    assert HyperInt.is_valid?([0]) == false
  end

  test "encode" do
    assert HyperInt.encode(0) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert HyperInt.encode(1) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 1>>}
    assert HyperInt.encode(-1) == {:ok, <<255, 255, 255, 255, 255, 255, 255, 255>>}
    assert @min_hyper_int |> HyperInt.encode == {:ok, <<128, 0, 0, 0, 0, 0, 0, 0>>}
    assert @max_hyper_int |> HyperInt.encode == {:ok, <<127, 255, 255, 255, 255, 255, 255, 255>>}

    assert HyperInt.encode(0.1) == {:error, :invalid}
    assert @min_hyper_int - 1 |> HyperInt.encode == {:error, :out_of_bounds}
    assert @max_hyper_int + 1 |> HyperInt.encode == {:error, :out_of_bounds}
  end

  test "decode" do
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, 0}
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 1}
    assert HyperInt.decode(<<255, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, -1}
    assert HyperInt.decode(<<128, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, @min_hyper_int}
    assert HyperInt.decode(<<127, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, @max_hyper_int}

    assert HyperInt.decode("0") == {:error, :invalid}
    assert HyperInt.decode(<<0, 0, 0, 0, 0, 0, 0, 0, 0>>) == {:error, :out_of_bounds}
    assert HyperInt.decode(<<127, 255, 255, 255, 255, 255, 255, 255, 255>>) == {:error, :out_of_bounds}
  end
end
