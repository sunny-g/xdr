defmodule XDR.Type.FixedArrayTest do
  use ExUnit.Case
  alias XDR.Type.Int
  alias XDR.Type.FixedArray
  doctest XDR.Type.FixedArray

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

  test "valid?" do
    assert XDR.Type.FixedArrayTest.Len1.valid?([0]) == true
    assert XDR.Type.FixedArrayTest.Len2.valid?([0, 1]) == true

    assert XDR.Type.FixedArrayTest.Len1.valid?([0, 0]) == false
    assert XDR.Type.FixedArrayTest.Len2.valid?([0, 0, 0]) == false
    assert XDR.Type.FixedArrayTest.Len1.valid?(false) == false
    assert XDR.Type.FixedArrayTest.Len1.valid?(nil) == false
    assert XDR.Type.FixedArrayTest.Len1.valid?(0) == false
  end

  test "encode" do
    assert XDR.Type.FixedArrayTest.Len0.encode([]) == {:ok, <<>>}
    assert XDR.Type.FixedArrayTest.Len1.encode([0]) == {:ok, <<0, 0, 0, 0>>}
    assert XDR.Type.FixedArrayTest.Len2.encode([1, 2]) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 2>>}
    assert XDR.Type.FixedArrayTest.Len2.encode([3, 4]) == {:ok, <<0, 0, 0, 3, 0, 0, 0, 4>>}

    assert XDR.Type.FixedArrayTest.Len1.encode([]) == {:error, :invalid}
    assert XDR.Type.FixedArrayTest.Len0.encode([1]) == {:error, :invalid}
  end

  test "decode" do
    assert XDR.Type.FixedArrayTest.Len0.decode(<<>>) == {:ok, []}
    assert XDR.Type.FixedArrayTest.Len0.decode(<<0, 0, 0, 0>>) == {:ok, []}
    assert XDR.Type.FixedArrayTest.Len1.decode(<<0, 0, 0, 0>>) == {:ok, [0]}
    assert XDR.Type.FixedArrayTest.Len1.decode(<<0, 0, 0, 1>>) == {:ok, [1]}
    assert XDR.Type.FixedArrayTest.Len2.decode(<<0, 0, 0, 0, 0, 0, 0, 1>>) == {:ok, [0, 1]}
    assert XDR.Type.FixedArrayTest.Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 1>>) == {:ok, [1, 1]}
    assert XDR.Type.FixedArrayTest.Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 2>>) == {:ok, [1, 2]}
    assert XDR.Type.FixedArrayTest.Len2.decode(<<0, 0, 0, 3, 0, 0, 0, 4>>) == {:ok, [3, 4]}
  end
end
