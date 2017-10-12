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

  alias XDR.Type.VariableOpaqueTest.{Len1, Len2, Len3, Len4}

  test "valid?" do
    assert Len2.valid?(<<>>) == true
    assert Len2.valid?(<<0>>) == true
    assert Len2.valid?(<<0, 0>>) == true

    assert Len1.valid?(<<0, 0>>) == false
    assert Len2.valid?(<<0, 0, 0>>) == false
    assert Len1.valid?(false) == false
    assert Len1.valid?(nil) == false
    assert Len1.valid?(0) == false
    assert Len1.valid?([0]) == false
  end

  test "encode" do
    assert Len2.encode(<<>>) == {:ok, <<0, 0, 0, 0>>}
    assert Len2.encode(<<0>>) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 0>>}
    assert Len2.encode(<<1>>) == {:ok, <<0, 0, 0, 1, 1, 0, 0, 0>>}
    assert Len2.encode(<<0, 1>>) == {:ok, <<0, 0, 0, 2, 0, 1, 0, 0>>}
  end

  test "decode" do
    assert Len2.decode(<<0, 0, 0, 0>>) == {:ok, <<>>}
    assert Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, <<0>>}
    assert Len2.decode(<<0, 0, 0, 1, 1, 0, 0, 0>>) == {:ok, <<1>>}
    assert Len2.decode(<<0, 0, 0, 2, 0, 1, 0, 0>>) == {:ok, <<0, 1>>}

    assert Len2.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert Len2.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>) == {:error, :xdr_length_exceeds_defined_max}
    assert Len2.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert Len2.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert Len2.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
