defmodule XDR.Type.FixedArrayTest do
  use ExUnit.Case
  alias XDR.Type.FixedArray
  alias XDR.Type.Int

  defmodule XDR.Type.FixedArrayTest.Len0 do
    use FixedArray, [len: 0, type: Int]
  end

  defmodule XDR.Type.FixedArrayTest.Len1 do
    use FixedArray, [len: 1, type: Int]
  end

  defmodule XDR.Type.FixedArrayTest.Len2 do
    use FixedArray, [len: 2, type: Int]
  end

  defmodule XDR.Type.FixedArrayTest.InvalidLength do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid length", fn ->
      use XDR.Type.FixedArray, [len: -1, type: Int]
    end
  end

  alias XDR.Type.FixedArrayTest.{Len0, Len1, Len2}

  test "new" do
    assert Len0.new([]) == {:ok, []}
    assert Len1.new([0]) == {:ok, [0]}
    assert Len1.new([1]) == {:ok, [1]}

    assert Len0.new([1]) == {:error, :invalid}
    assert Len1.new([]) == {:error, :invalid}
    assert Len1.new([0, 1]) == {:error, :invalid}
    assert Len0.new({1}) == {:error, :invalid}
    assert Len1.new({0, 1}) == {:error, :invalid}
    assert Len0.new(false) == {:error, :invalid}
    assert Len0.new(nil) == {:error, :invalid}
    assert Len0.new(0) == {:error, :invalid}
  end

  test "valid?" do
    assert Len1.valid?([0]) == true
    assert Len2.valid?([0, 1]) == true

    assert Len1.valid?([0, 0]) == false
    assert Len2.valid?([0, 0, 0]) == false
    assert Len1.valid?(false) == false
    assert Len1.valid?(nil) == false
    assert Len1.valid?(0) == false
  end

  test "encode" do
    assert Len0.encode([]) == {:ok, <<>>}
    assert Len1.encode([0]) == {:ok, <<0, 0, 0, 0>>}
    assert Len1.encode([1]) == {:ok, <<0, 0, 0, 1>>}
    assert Len2.encode([1, 2]) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 2>>}
    assert Len2.encode([3, 4]) == {:ok, <<0, 0, 0, 3, 0, 0, 0, 4>>}

    assert Len1.encode([]) == {:error, :invalid}
    assert Len0.encode([1]) == {:error, :invalid}
  end

  test "decode" do
    assert Len0.decode(<<>>) == {:ok, []}
    assert Len0.decode(<<0, 0, 0, 0>>) == {:ok, []}
    assert Len1.decode(<<0, 0, 0, 0>>) == {:ok, [0]}
    assert Len1.decode(<<0, 0, 0, 1>>) == {:ok, [1]}
    assert Len2.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, [0, 1]}
    assert Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 1>>) == {:ok, [1, 1]}
    assert Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 2>>) == {:ok, [1, 2]}
    assert Len2.decode(<<0, 0, 0, 3, 0, 0, 0, 4>>) == {:ok, [3, 4]}
  end
end
