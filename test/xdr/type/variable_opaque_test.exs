defmodule XDR.Type.VariableOpaqueTest do
  use ExUnit.Case
  require Math
  alias XDR.Type.VariableOpaque
  doctest XDR.Type.VariableOpaque

  test "is_valid?" do
    assert VariableOpaque.is_valid?(<<>>, 2) == true
    assert VariableOpaque.is_valid?(<<0>>, 2) == true
    assert VariableOpaque.is_valid?(<<0, 0>>, 2) == true

    assert VariableOpaque.is_valid?(<<0, 0>>, 1) == false
    assert VariableOpaque.is_valid?(<<0, 0, 0>>, 2) == false
    assert VariableOpaque.is_valid?(false, 1) == false
    assert VariableOpaque.is_valid?(nil, 1) == false
    assert VariableOpaque.is_valid?(0, 1) == false
    assert VariableOpaque.is_valid?([0], 1) == false
  end

  test "encode" do
    assert VariableOpaque.encode(<<>>, 2) == {:ok, <<0, 0, 0, 0>>}
    assert VariableOpaque.encode(<<0>>, 2) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 0>>}
    assert VariableOpaque.encode(<<1>>, 2) == {:ok, <<0, 0, 0, 1, 1, 0, 0, 0>>}
    assert VariableOpaque.encode(<<0, 1>>, 2) == {:ok, <<0, 0, 0, 2, 0, 1, 0, 0>>}
  end

  test "decode" do
    assert VariableOpaque.decode(<<0, 0, 0, 0>>, 2) == {:ok, <<>>}
    assert VariableOpaque.decode(<<0, 0, 0, 1, 0, 0, 0, 0>>, 2) == {:ok, <<0>>}
    assert VariableOpaque.decode(<<0, 0, 0, 1, 1, 0, 0, 0>>, 2) == {:ok, <<1>>}
    assert VariableOpaque.decode(<<0, 0, 0, 2, 0, 1, 0, 0>>, 2) == {:ok, <<0, 1>>}

    assert VariableOpaque.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>, Math.pow(2, 32)) == {:error, :max_length_too_large}
    assert VariableOpaque.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>, 2) == {:error, :xdr_length_exceeds_max}
    assert VariableOpaque.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>, Math.pow(2, 32) - 1) == {:error, :invalid_xdr_length}
    assert VariableOpaque.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert VariableOpaque.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert VariableOpaque.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
