defmodule XDR.Type.FixedOpaqueTest do
  use ExUnit.Case
  alias XDR.Type.FixedOpaque

  defmodule XDR.Type.FixedOpaqueTest.Len1 do
    use FixedOpaque, len: 1
  end

  defmodule XDR.Type.FixedOpaqueTest.Len2 do
    use FixedOpaque, len: 2
  end

  defmodule XDR.Type.FixedOpaqueTest.Len3 do
    use FixedOpaque, len: 3
  end

  defmodule XDR.Type.FixedOpaqueTest.Len5 do
    use FixedOpaque, len: 5
  end

  defmodule XDR.Type.FixedOpaqueTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid length", fn ->
      use XDR.Type.FixedOpaque, len: -1
    end
  end

  alias XDR.Type.FixedOpaqueTest.{Len1, Len2, Len3, Len5}

  test "new" do
    assert Len1.new(<<0>>) == {:ok, <<0>>}
    assert Len1.new(<<1>>) == {:ok, <<1>>}
    assert Len1.new("a") == {:ok, "a"}
    assert Len2.new(<<0, 1>>) == {:ok, <<0, 1>>}
    assert Len2.new("ab") == {:ok, "ab"}

    assert Len1.new(<<0, 1>>) == {:error, :invalid}
    assert Len2.new(<<0, 0, 1>>) == {:error, :invalid}
    assert Len1.new(false) == {:error, :invalid}
    assert Len1.new(nil) == {:error, :invalid}
    assert Len1.new(0) == {:error, :invalid}
    assert Len1.new([]) == {:error, :invalid}
    assert Len1.new({}) == {:error, :invalid}
  end

  test "valid?" do
    assert Len1.valid?(<<1>>) == true
    assert Len2.valid?(<<0, 1>>) == true
    assert Len3.valid?(<<0, 0, 0>>) == true

    assert Len1.valid?(<<0, 0>>) == false
    assert Len2.valid?(<<0, 0, 0>>) == false
    assert Len1.valid?(false) == false
    assert Len1.valid?(nil) == false
    assert Len1.valid?(0) == false
  end

  test "encode" do
    assert Len3.encode(<<0, 0, 0>>) == {:ok, <<0, 0, 0, 0>>}
    assert Len3.encode(<<0, 0, 1>>) == {:ok, <<0, 0, 1, 0>>}
  end

  test "decode" do
    assert Len3.decode(<<0, 0, 0, 0>>) == {:ok, <<0, 0, 0>>}
    assert Len3.decode(<<0, 0, 1, 0>>) == {:ok, <<0, 0, 1>>}

    assert Len5.decode(<<0, 0, 0, 0>>) == {:error, :out_of_bounds}
  end
end
