defmodule XDR.Type.FixedOpaqueTest do
  use ExUnit.Case
  alias XDR.Type.FixedOpaque
  doctest XDR.Type.FixedOpaque

  test "is_valid?" do
    assert FixedOpaque.is_valid?(<<0, 0, 0>>, 3) == true
    assert FixedOpaque.is_valid?(<<0, 1>>, 2) == true

    assert FixedOpaque.is_valid?(<<0, 0>>, 1) == false
    assert FixedOpaque.is_valid?(<<0, 0, 0>>, 2) == false
    assert FixedOpaque.is_valid?(false, 1) == false
    assert FixedOpaque.is_valid?(nil, 1) == false
    assert FixedOpaque.is_valid?(0, 1) == false
  end

  test "encode" do
    assert FixedOpaque.encode(<<0, 0, 0>>, 3) == {:ok, <<0, 0, 0, 0>>}
    assert FixedOpaque.encode(<<0, 0, 1>>, 3) == {:ok, <<0, 0, 1, 0>>}
  end

  test "decode" do
    assert FixedOpaque.decode(<<0, 0, 0, 0>>, 3) == {:ok, <<0, 0, 0>>}
    assert FixedOpaque.decode(<<0, 0, 1, 0>>, 3) == {:ok, <<0, 0, 1>>}
  end
end
