defmodule XDR.Type.HyperUintTest do
  @moduledoc false

  use ExUnit.Case, async: true
  require Math
  alias XDR.Type.HyperUint

  @min_hyper_uint 0
  @max_hyper_uint Math.pow(2, 64) - 1

  test "length" do
    assert HyperUint.length() === 8
  end

  test "new" do
    assert HyperUint.new() === {:ok, 0}
    assert HyperUint.new(@min_hyper_uint) === {:ok, @min_hyper_uint}
    assert HyperUint.new(@max_hyper_uint) === {:ok, @max_hyper_uint}

    assert HyperUint.new(@min_hyper_uint - 1) === {:error, :invalid}
    assert HyperUint.new(@max_hyper_uint + 1) === {:error, :invalid}
    assert HyperUint.new(<<1>>) === {:error, :invalid}
    assert HyperUint.new("1") === {:error, :invalid}
    assert HyperUint.new(nil) === {:error, :invalid}
    assert HyperUint.new(false) === {:error, :invalid}
  end

  test "valid?" do
    assert HyperUint.valid?(1) == true
    assert HyperUint.valid?(@min_hyper_uint) == true
    assert HyperUint.valid?(@max_hyper_uint) == true

    assert HyperUint.valid?(-1) == false
    assert HyperUint.valid?(0.0) == false
    assert HyperUint.valid?(-0.1) == false
    assert HyperUint.valid?(:math.pow(2, 64) - 1) == false
    assert HyperUint.valid?(@min_hyper_uint - 1) == false
    assert HyperUint.valid?(@max_hyper_uint + 1) == false
    assert HyperUint.valid?(true) == false
    assert HyperUint.valid?(false) == false
    assert HyperUint.valid?(nil) == false
    assert HyperUint.valid?("0") == false
    assert HyperUint.valid?({}) == false
    assert HyperUint.valid?([]) == false
    assert HyperUint.valid?([0]) == false
  end

  test "encode" do
    assert HyperUint.encode(1) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 1>>}
    assert HyperUint.encode(@min_hyper_uint) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert HyperUint.encode(@max_hyper_uint) == {:ok, <<255, 255, 255, 255, 255, 255, 255, 255>>}

    assert HyperUint.encode(0.1) == {:error, :invalid}
    assert HyperUint.encode(@min_hyper_uint - 1) == {:error, :out_of_bounds}
    assert HyperUint.encode(@max_hyper_uint + 1) == {:error, :out_of_bounds}
  end

  test "decode" do
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, {1, <<>>}}
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, {1, <<0, 0, 0, 0>>}}
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, {@min_hyper_uint, <<>>}}

    assert HyperUint.decode(<<255, 255, 255, 255, 255, 255, 255, 255>>) ==
             {:ok, {@max_hyper_uint, <<>>}}
  end
end
