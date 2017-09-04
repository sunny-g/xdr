defmodule XDR.Type.HyperUintTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.HyperUint
  doctest XDR.Type.HyperUint

  @min_hyper_uint 0
  @max_hyper_uint Math.pow(2, 64) - 1

  test "is_valid?" do
    assert HyperUint.is_valid?(1) == true
    assert HyperUint.is_valid?(@min_hyper_uint) == true
    assert HyperUint.is_valid?(@max_hyper_uint) == true

    assert HyperUint.is_valid?(-1) == false
    assert HyperUint.is_valid?(0.0) == false
    assert HyperUint.is_valid?(-0.1) == false
    assert HyperUint.is_valid?(:math.pow(2, 64) - 1) == false
    assert HyperUint.is_valid?(@min_hyper_uint - 1) == false
    assert HyperUint.is_valid?(@max_hyper_uint + 1) == false
    assert HyperUint.is_valid?(true) == false
    assert HyperUint.is_valid?(false) == false
    assert HyperUint.is_valid?(nil) == false
    assert HyperUint.is_valid?("0") == false
    assert HyperUint.is_valid?({}) == false
    assert HyperUint.is_valid?([]) == false
    assert HyperUint.is_valid?([0]) == false
  end

  test "encode" do
    assert HyperUint.encode(1) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 1>>}
    assert @min_hyper_uint |> HyperUint.encode == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert @max_hyper_uint |> HyperUint.encode == {:ok, <<255, 255, 255, 255, 255, 255, 255, 255>>}

    assert HyperUint.encode(0.1) == {:error, :invalid}
    assert HyperUint.encode(@min_hyper_uint - 1) == {:error, :out_of_bounds}
    assert HyperUint.encode(@max_hyper_uint + 1) == {:error, :out_of_bounds}

  end

  test "decode" do
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 1}
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, @min_hyper_uint}
    assert HyperUint.decode(<<255, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, @max_hyper_uint}
  end
end
