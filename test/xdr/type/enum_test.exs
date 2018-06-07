defmodule XDR.Type.EnumTest do
  use ExUnit.Case
  alias XDR.Type.Enum
  alias XDR.Type.Int

  defmodule XDR.Type.EnumTest.DummyEnum do
    use Enum,
      spec: [
        red: 0,
        green: 1,
        evenMoreGreen: 3
      ]
  end

  defmodule XDR.Type.EnumTest.NegativeEnum do
    use Enum,
      spec: [
        zero: 0,
        one: -1,
        two: -2
      ]
  end

  defmodule XDR.Type.EnumTest.InvalidSpec do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "Enum spec must be a keyword list", fn ->
      use XDR.Type.Enum, spec: %{}
    end
  end

  defmodule XDR.Type.EnumTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "all Enum values must be numbers", fn ->
      use XDR.Type.Enum, spec: [a: "a"]
    end
  end

  alias XDR.Type.EnumTest.{DummyEnum, NegativeEnum}

  test "length" do
    assert DummyEnum.length() === 4
  end

  test "new" do
    assert DummyEnum.new(:red) == {:ok, :red}
    assert DummyEnum.new(:green) == {:ok, :green}
    assert DummyEnum.new(:evenMoreGreen) == {:ok, :evenMoreGreen}

    assert DummyEnum.new(:blue) == {:error, :invalid}
    assert DummyEnum.new(0) == {:error, :invalid}
    assert DummyEnum.new(1) == {:error, :invalid}
    assert DummyEnum.new(2) == {:error, :invalid}
  end

  test "valid?" do
    assert DummyEnum.valid?(:red) == true
    assert DummyEnum.valid?(:green) == true
    assert DummyEnum.valid?(:evenMoreGreen) == true

    assert DummyEnum.valid?(:blue) == false
    assert DummyEnum.valid?("red") == false
    assert DummyEnum.valid?("green") == false
    assert DummyEnum.valid?("evenMoreGreen") == false
    assert DummyEnum.valid?(true) == false
    assert DummyEnum.valid?(nil) == false
    assert DummyEnum.valid?([]) == false
    assert DummyEnum.valid?({}) == false
  end

  test "encode" do
    assert DummyEnum.encode(:red) == Int.encode(0)
    assert DummyEnum.encode(:green) == Int.encode(1)
    assert DummyEnum.encode(:evenMoreGreen) == Int.encode(3)
    assert NegativeEnum.encode(:zero) == Int.encode(0)
    assert NegativeEnum.encode(:one) == Int.encode(-1)
    assert NegativeEnum.encode(:two) == Int.encode(-2)

    assert DummyEnum.encode(:blue) == {:error, :invalid}
  end

  test "decode" do
    assert DummyEnum.decode(<<0, 0, 0, 0>>) == {:ok, {:red, <<>>}}
    assert DummyEnum.decode(<<0, 0, 0, 1>>) == {:ok, {:green, <<>>}}
    assert DummyEnum.decode(<<0, 0, 0, 3>>) == {:ok, {:evenMoreGreen, <<>>}}
    assert DummyEnum.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>) == {:ok, {:evenMoreGreen, <<0, 0, 0, 0>>}}
    assert NegativeEnum.decode(<<0, 0, 0, 0>>) == {:ok, {:zero, <<>>}}
    assert NegativeEnum.decode(<<255, 255, 255, 255>>) == {:ok, {:one, <<>>}}
    assert NegativeEnum.decode(<<255, 255, 255, 254>>) == {:ok, {:two, <<>>}}

    assert DummyEnum.decode(<<0, 0, 0, 2>>) == {:error, :invalid_enum}
    assert DummyEnum.decode(<<0, 0, 1>>) == {:error, :invalid_xdr}
  end
end
