defmodule XDR.Type.UintTest do
  use ExUnit.Case
  require Math
  import XDR.Type.Uint.Validation
  alias XDR.Type.Uint
  doctest XDR.Type.Uint

  @min_int 0
  @max_int Math.pow(2, 32) - 1

  test "is_valid?" do
    assert is_valid?(1) == true
    assert is_valid?(@min_int) == true
    assert is_valid?(@max_int) == true

    assert is_valid?(-1) == false
    assert is_valid?(0.0) == false
    assert is_valid?(-0.1) == false
    assert is_valid?(:math.pow(2, 32) - 1) == false
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
    assert Uint.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert @min_int |> Uint.encode == {:ok, <<0, 0, 0, 0>>}
    assert @max_int |> Uint.encode == {:ok, <<255, 255, 255, 255>>}

    assert Uint.encode(0.1) == {:error, :invalid}
    assert Uint.encode(@min_int - 1) == {:error, :out_of_bounds}
    assert Uint.encode(@max_int + 1) == {:error, :out_of_bounds}

  end

  test "decode" do
    assert Uint.decode(<<0, 0, 0, 1>>) == {:ok, 1}
    assert Uint.decode(<<0, 0, 0, 0>>) == {:ok, @min_int}
    assert Uint.decode(<<255, 255, 255, 255>>) == {:ok, @max_int}
  end
end
