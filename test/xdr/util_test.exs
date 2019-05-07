defmodule XDR.Util.DelegateTest.Int32 do
  use XDR.Util.Delegate, to: XDR.Type.Int
end

defmodule XDR.Util.DelegateTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias XDR.Util.DelegateTest.Int32

  @min_int -2_147_483_648
  @max_int 2_147_483_647

  test "length" do
    assert Int32.length() === 4
  end

  test "new" do
    assert Int32.new() === {:ok, 0}
    assert Int32.new(0) === {:ok, 0}
    assert Int32.new(1) === {:ok, 1}
    assert Int32.new(@min_int) === {:ok, @min_int}
    assert Int32.new(@max_int) === {:ok, @max_int}

    assert Int32.new(@min_int - 1) === {:error, :invalid}
    assert Int32.new(@max_int + 1) === {:error, :invalid}
    assert Int32.new("0") === {:error, :invalid}
    assert Int32.new(nil) === {:error, :invalid}
    assert Int32.new(false) === {:error, :invalid}
    assert Int32.new([]) === {:error, :invalid}
    assert Int32.new({}) === {:error, :invalid}
  end

  test "valid?" do
    assert Int32.valid?(0) == true
    assert Int32.valid?(1) == true
    assert Int32.valid?(-1) == true
    assert Int32.valid?(@min_int) == true
    assert Int32.valid?(@max_int) == true

    assert Int32.valid?(0.0) == false
    assert Int32.valid?(-0.1) == false
    assert Int32.valid?(-:math.pow(2, 31)) == false
    assert Int32.valid?(:math.pow(2, 31) - 1) == false
    assert Int32.valid?(@min_int - 1) == false
    assert Int32.valid?(@max_int + 1) == false
    assert Int32.valid?(true) == false
    assert Int32.valid?(false) == false
    assert Int32.valid?(nil) == false
    assert Int32.valid?("0") == false
    assert Int32.valid?({}) == false
    assert Int32.valid?([]) == false
    assert Int32.valid?([0]) == false
  end

  test "encode" do
    assert Int32.encode(0) == {:ok, <<0, 0, 0, 0>>}
    assert Int32.encode(1) == {:ok, <<0, 0, 0, 1>>}
    assert Int32.encode(-1) == {:ok, <<255, 255, 255, 255>>}
    assert Int32.encode(@min_int) == {:ok, <<128, 0, 0, 0>>}
    assert Int32.encode(@max_int) == {:ok, <<127, 255, 255, 255>>}

    assert Int32.encode(0.1) == {:error, :invalid}
    assert Int32.encode(@min_int - 1) == {:error, :out_of_bounds}
    assert Int32.encode(@max_int + 1) == {:error, :out_of_bounds}
  end

  test "decode" do
    assert Int32.decode(<<0, 0, 0, 0>>) == {:ok, {0, <<>>}}
    assert Int32.decode(<<0, 0, 0, 1>>) == {:ok, {1, <<>>}}
    assert Int32.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, {1, <<0, 0, 0, 0>>}}
    assert Int32.decode(<<255, 255, 255, 255>>) == {:ok, {-1, <<>>}}
    assert Int32.decode(<<128, 0, 0, 0>>) == {:ok, {@min_int, <<>>}}
    assert Int32.decode(<<127, 255, 255, 255>>) == {:ok, {@max_int, <<>>}}

    assert Int32.decode("0") == {:error, :invalid}
    assert Int32.decode(<<0, 0, 0, 0, 0>>) == {:error, :invalid}
    assert Int32.decode(<<127, 255, 255, 255, 255>>) == {:error, :invalid}
  end
end
