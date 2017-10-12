defmodule XDR.Type.VariableArrayTest do
  use ExUnit.Case
  alias XDR.Type.Int
  alias XDR.Type.VariableArray
  doctest XDR.Type.VariableArray

  defmodule XDR.Type.VariableArrayTest.Max0 do
    use VariableArray, [max: 0, type: Int]
  end

  defmodule XDR.Type.VariableArrayTest.Max1 do
    use VariableArray, [max: 1, type: Int]
  end

  defmodule XDR.Type.VariableArrayTest.Max2 do
    use VariableArray, [max: 2, type: Int]
  end

  defmodule XDR.Type.VariableArrayTest.InvalidLength do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid length", fn ->
      use XDR.Type.VariableArray, [max: -1, type: Int]
    end
  end

  test "valid?" do
    assert XDR.Type.VariableArrayTest.Max2.valid?([0]) == true
    assert XDR.Type.VariableArrayTest.Max2.valid?([0, 1]) == true

    assert XDR.Type.VariableArrayTest.Max1.valid?([0, 0]) == false
    assert XDR.Type.VariableArrayTest.Max2.valid?([0, 0, 0]) == false
    assert XDR.Type.VariableArrayTest.Max1.valid?(false) == false
    assert XDR.Type.VariableArrayTest.Max1.valid?(nil) == false
    assert XDR.Type.VariableArrayTest.Max1.valid?(0) == false
  end

  test "encode" do
    assert XDR.Type.VariableArrayTest.Max0.encode([]) == {:ok, <<0, 0, 0, 0>>}
    assert XDR.Type.VariableArrayTest.Max1.encode([0]) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 0>>}
    assert XDR.Type.VariableArrayTest.Max2.encode([1, 2]) == {:ok, <<0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2>>}
    assert XDR.Type.VariableArrayTest.Max2.encode([3, 4]) == {:ok, <<0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4>>}
  end

  test "decode" do
    assert XDR.Type.VariableArrayTest.Max0.decode(<<0, 0, 0, 0>>) == {:ok, []}
    assert XDR.Type.VariableArrayTest.Max1.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>) == {:ok, [0]}
    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 1, 0, 0, 0, 1>>) == {:ok, [1]}
    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2>>) == {:ok, [1, 2]}
    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4>>) == {:ok, [3, 4]}

    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>) == {:error, :xdr_length_exceeds_defined_max}
    assert XDR.Type.VariableArrayTest.Max2.decode(<<0, 0, 0, 2, 0, 0, 0, 1>>) == {:error, :invalid_xdr_length}
  end
end