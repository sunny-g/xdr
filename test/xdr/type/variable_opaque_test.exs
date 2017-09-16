defmodule XDR.Type.VariableOpaqueTest do
  use ExUnit.Case
  import CompileTimeAssertions
  require Math
  alias XDR.Type.VariableOpaque
  doctest XDR.Type.VariableOpaque

  defmodule XDR.Type.VariableOpaqueTest.Len1 do
    use VariableOpaque, max: 1
  end

  defmodule XDR.Type.VariableOpaqueTest.Len2 do
    use VariableOpaque, max: 2
  end

  defmodule XDR.Type.VariableOpaqueTest.Len3 do
    use VariableOpaque, max: 3
  end

  defmodule XDR.Type.VariableOpaqueTest.Len4 do
    use VariableOpaque, max: 4
  end

  defmodule XDR.Type.VariableOpaqueTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "max length too large", fn ->
      use XDR.Type.VariableOpaque, max: Math.pow(2, 32)
    end
  end

  test "valid?" do
    assert XDR.Type.VariableOpaqueTest.Len2.valid?(<<>>) == true
    assert XDR.Type.VariableOpaqueTest.Len2.valid?(<<0>>) == true
    assert XDR.Type.VariableOpaqueTest.Len2.valid?(<<0, 0>>) == true

    assert XDR.Type.VariableOpaqueTest.Len1.valid?(<<0, 0>>) == false
    assert XDR.Type.VariableOpaqueTest.Len2.valid?(<<0, 0, 0>>) == false
    assert XDR.Type.VariableOpaqueTest.Len1.valid?(false) == false
    assert XDR.Type.VariableOpaqueTest.Len1.valid?(nil) == false
    assert XDR.Type.VariableOpaqueTest.Len1.valid?(0) == false
    assert XDR.Type.VariableOpaqueTest.Len1.valid?([0]) == false
  end

  test "encode" do
    assert XDR.Type.VariableOpaqueTest.Len2.encode(<<>>) == {:ok, <<0, 0, 0, 0>>}
    assert XDR.Type.VariableOpaqueTest.Len2.encode(<<0>>) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 0>>}
    assert XDR.Type.VariableOpaqueTest.Len2.encode(<<1>>) == {:ok, <<0, 0, 0, 1, 1, 0, 0, 0>>}
    assert XDR.Type.VariableOpaqueTest.Len2.encode(<<0, 1>>) == {:ok, <<0, 0, 0, 2, 0, 1, 0, 0>>}
  end

  test "decode" do
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 0>>) == {:ok, <<>>}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, <<0>>}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 1, 0, 0, 0>>) == {:ok, <<1>>}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 2, 0, 1, 0, 0>>) == {:ok, <<0, 1>>}

    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>) == {:error, :xdr_length_exceeds_defined_max}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert XDR.Type.VariableOpaqueTest.Len2.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
