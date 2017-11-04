defmodule XDR.Type.VariableOpaqueTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.VariableOpaque

  defmodule XDR.Type.VariableOpaqueTest.Len1 do
    use VariableOpaque, max_len: 1
  end

  defmodule XDR.Type.VariableOpaqueTest.Len2 do
    use VariableOpaque, max_len: 2
  end

  defmodule XDR.Type.VariableOpaqueTest.Len3 do
    use VariableOpaque, max_len: 3
  end

  defmodule XDR.Type.VariableOpaqueTest.Len4 do
    use VariableOpaque, max_len: 4
  end

  defmodule XDR.Type.VariableOpaqueTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "max length too large", fn ->
      use XDR.Type.VariableOpaque, max_len: Math.pow(2, 32)
    end
  end

  alias XDR.Type.VariableOpaqueTest.{Len1, Len2, Len3, Len4}

  test "length" do
    assert Len1.length === :variable
    assert Len2.length === :variable
    assert Len3.length === :variable
    assert Len4.length === :variable
  end

  test "new" do
    assert Len1.new == {:ok, <<>>}
    assert Len1.new(<<>>) == {:ok, <<>>}
    assert Len1.new(<<0>>) == {:ok, <<0>>}
    assert Len1.new(<<1>>) == {:ok, <<1>>}
    assert Len1.new("a") == {:ok, "a"}

    assert Len1.new(false) == {:error, :invalid}
    assert Len1.new(nil) == {:error, :invalid}
    assert Len1.new(0) == {:error, :invalid}
    assert Len1.new([]) == {:error, :invalid}
    assert Len1.new({}) == {:error, :invalid}
  end

  test "valid?" do
    assert Len2.valid?(<<>>) == true
    assert Len2.valid?(<<0>>) == true
    assert Len2.valid?(<<0, 0>>) == true
    assert Len3.valid?(<<0, 0, 0>>) == true

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
    assert Len3.encode(<<0, 0, 1>>) == {:ok, <<0, 0, 0, 3, 0, 0, 1, 0>>}
    assert Len4.encode(<<0, 0, 1, 0>>) == {:ok, <<0, 0, 0, 4, 0, 0, 1, 0>>}
  end

  test "decode" do
    assert Len1.decode(<<0, 0, 0, 0>>) == {:ok, {<<>>, <<>>}}
    assert Len1.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, {<<>>, <<0, 0, 0, 0>>}}
    assert Len1.decode(<<0, 0, 0, 1, 1, 0, 0, 0>>) == {:ok, {<<1>>, <<>>}}
    assert Len2.decode(<<0, 0, 0, 0>>) == {:ok, {<<>>, <<>>}}
    assert Len2.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, {<<>>, <<0, 0, 0, 0>>}}
    assert Len2.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, {<<0>>, <<>>}}
    assert Len2.decode(<<0, 0, 0, 1, 1, 0, 0, 0>>) == {:ok, {<<1>>, <<>>}}
    assert Len2.decode(<<0, 0, 0, 2, 0, 1, 0, 0>>) == {:ok, {<<0, 1>>, <<>>}}
    assert Len3.decode(<<0, 0, 0, 3, 0, 0, 1, 0>>) == {:ok, {<<0, 0, 1>>, <<>>}}
    assert Len4.decode(<<0, 0, 0, 4, 0, 0, 1, 0>>) == {:ok, {<<0, 0, 1, 0>>, <<>>}}

    assert Len2.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert Len2.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>) == {:error, :xdr_length_exceeds_defined_max}
    assert Len2.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert Len2.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert Len2.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
