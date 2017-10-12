defmodule XDR.Type.EnumTest do
  use ExUnit.Case
  alias XDR.Type.Enum
  alias XDR.Type.Int
  doctest XDR.Type.Enum

  defmodule XDR.Type.EnumTest.DummyEnum do
    use Enum, spec: [
      red: 0,
      green: 1,
      evenMoreGreen: 3,
    ]
  end

  defmodule XDR.Type.EnumTest.InvalidSpec do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid Enum spec", fn ->
      use XDR.Type.Enum, spec: %{}
    end
  end

  defmodule XDR.Type.EnumTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "all Enum values must be numbers", fn ->
      use XDR.Type.Enum, spec: [a: "a"]
    end
  end

  alias XDR.Type.EnumTest.DummyEnum

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

    assert DummyEnum.encode(:blue) == {:error, :invalid}
  end

  test "decode" do
    assert Int.encode(0)
      |> elem(1)
      |> DummyEnum.decode == {:ok, :red}
    assert Int.encode(1)
      |> elem(1)
      |> DummyEnum.decode == {:ok, :green}
    assert Int.encode(3)
      |> elem(1)
      |> DummyEnum.decode == {:ok, :evenMoreGreen}

    assert Int.encode(2)
      |> elem(1)
      |> DummyEnum.decode == {:error, :invalid_enum}
    assert DummyEnum.decode(<<0, 0, 1>>) == {:error, :invalid_xdr}
  end
end
