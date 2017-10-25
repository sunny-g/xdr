defmodule XDR.Type.OptionalTest do
  use ExUnit.Case
  alias XDR.Type.Optional
  alias XDR.Type.Int

  defmodule XDR.Type.OptionalTest.OptionalInt do
    use Optional, for: Int
  end

  alias XDR.Type.OptionalTest.OptionalInt

  test "new" do
    assert OptionalInt.new(0) == {:ok, 0}
    assert OptionalInt.new(1) == {:ok, 1}
    assert OptionalInt.new(-1) == {:ok, -1}
    assert OptionalInt.new(3) == {:ok, 3}
    assert OptionalInt.new(nil) == {:ok, nil}

    assert OptionalInt.new(false) == {:error, :invalid}
    assert OptionalInt.new("0") == {:error, :invalid}
    assert OptionalInt.new({}) == {:error, :invalid}
    assert OptionalInt.new([]) == {:error, :invalid}
  end

  test "valid?" do
    assert OptionalInt.valid?(0) == true
    assert OptionalInt.valid?(1) == true
    assert OptionalInt.valid?(-1) == true
    assert OptionalInt.valid?(3) == true
    assert OptionalInt.valid?(nil) == true

    assert OptionalInt.valid?(false) == false
    assert OptionalInt.valid?("0") == false
    assert OptionalInt.valid?({}) == false
    assert OptionalInt.valid?([]) == false
  end

  test "encode" do
    assert OptionalInt.encode(0) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 0>>}
    assert OptionalInt.encode(1) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 1>>}
    assert OptionalInt.encode(-1) == {:ok, <<0, 0, 0, 1, 255, 255, 255, 255>>}
    assert OptionalInt.encode(3) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 3>>}
    assert OptionalInt.encode(nil) == {:ok, <<0, 0, 0, 0>>}

    assert OptionalInt.encode(false) == {:error, :invalid}
    assert OptionalInt.encode("0") == {:error, :invalid}
    assert OptionalInt.encode({}) == {:error, :invalid}
    assert OptionalInt.encode([]) == {:error, :invalid}
  end

  test "decode" do
    assert OptionalInt.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, 0}
    assert OptionalInt.decode(<<0, 0, 0, 1, 0, 0, 0, 1>>) == {:ok, 1}
    assert OptionalInt.decode(<<0, 0, 0, 1, 255, 255, 255, 255>>) == {:ok, -1}
    assert OptionalInt.decode(<<0, 0, 0, 1, 0, 0, 0, 3>>) == {:ok, 3}
    assert OptionalInt.decode(<<0, 0, 0, 0>>) == {:ok, nil}

    assert OptionalInt.decode(<<0, 0, 0, 1>>) == {:error, :invalid}
    assert OptionalInt.decode(<<0, 0, 0, 2>>) == {:error, :invalid_enum}
    assert OptionalInt.decode(<<255, 255, 255, 255>>) == {:error, :invalid_enum}
  end
end
