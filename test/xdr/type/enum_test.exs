defmodule XDR.Type.EnumTest do
  use ExUnit.Case
  alias XDR.Type.Enum
  alias XDR.Type.Int
  doctest XDR.Type.Enum

  @color_enum %{
    red: 0,
    green: 1,
    evenMoreGreen: 3,
  }

  test "is_valid?" do
    assert Enum.is_valid?(:red, @color_enum) == true
    assert Enum.is_valid?(:green, @color_enum) == true
    assert Enum.is_valid?(:evenMoreGreen, @color_enum) == true

    assert Enum.is_valid?(:blue, @color_enum) == false
    assert Enum.is_valid?("red", @color_enum) == false
    assert Enum.is_valid?("green", @color_enum) == false
    assert Enum.is_valid?("evenMoreGreen", @color_enum) == false
    assert Enum.is_valid?(true, @color_enum) == false
    assert Enum.is_valid?(nil, @color_enum) == false
    assert Enum.is_valid?([], @color_enum) == false
    assert Enum.is_valid?({}, @color_enum) == false
  end

  test "encode" do
    assert Enum.encode(:red, @color_enum) == Int.encode(0)
    assert Enum.encode(:green, @color_enum) == Int.encode(1)
    assert Enum.encode(:evenMoreGreen, @color_enum) == Int.encode(3)

    assert Enum.encode(:blue, @color_enum) == {:error, :invalid}
  end

  test "decode" do
    assert Int.encode(0)
      |> elem(1)
      |> Enum.decode(@color_enum) == {:ok, :red}
    assert Int.encode(1)
      |> elem(1)
      |> Enum.decode(@color_enum) == {:ok, :green}
    assert Int.encode(3)
      |> elem(1)
      |> Enum.decode(@color_enum) == {:ok, :evenMoreGreen}

    assert Int.encode(2)
      |> elem(1)
      |> Enum.decode(@color_enum) == {:error, :invalid}
  end
end
