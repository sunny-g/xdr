defmodule XDR.Type.VoidTest do
  use ExUnit.Case
  alias XDR.Type.Void
  doctest XDR.Type.Void

  test "valid?" do
    assert Void.valid?(nil) == true

    assert Void.valid?(false) == false
    assert Void.valid?(0) == false
    assert Void.valid?("0") == false
    assert Void.valid?([]) == false
    assert Void.valid?({}) == false
  end

  test "encode" do
    assert Void.encode(nil) == {:ok, <<>>}
    assert Void.encode(false) == {:error, :invalid}
  end

  test "decode" do
    assert Void.decode(<<>>) == {:ok, nil}
    assert Void.decode(nil) == {:error, :invalid}
    assert Void.decode(false) == {:error, :invalid}
  end
end
