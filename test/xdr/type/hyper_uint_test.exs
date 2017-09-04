defmodule XDR.Type.HyperUintTest do
  use ExUnit.Case
  require Math
  import XDR.Type.HyperUint.Validation
  alias XDR.Type.HyperUint
  doctest XDR.Type.HyperUint

  @min_int 0
  @max_int Math.pow(2, 64) - 1

  test "is_valid?" do
    assert is_valid?(1) == true
    assert is_valid?(@min_int) == true
    assert is_valid?(@max_int) == true

    assert is_valid?(-1) == false
    assert is_valid?(0.0) == false
    assert is_valid?(-0.1) == false
    assert is_valid?(:math.pow(2, 64) - 1) == false
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
    assert HyperUint.encode(1) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 1>>}
    assert @min_int |> HyperUint.encode == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0>>}
    assert @max_int |> HyperUint.encode == {:ok, <<255, 255, 255, 255, 255, 255, 255, 255>>}

    assert HyperUint.encode(0.1) == {:error, :invalid}
    assert HyperUint.encode(@min_int - 1) == {:error, :out_of_bounds}
    assert HyperUint.encode(@max_int + 1) == {:error, :out_of_bounds}

  end

  test "decode" do
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, 1}
    assert HyperUint.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, @min_int}
    assert HyperUint.decode(<<255, 255, 255, 255, 255, 255, 255, 255>>) == {:ok, @max_int}
  end
end
