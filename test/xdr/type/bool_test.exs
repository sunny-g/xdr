defmodule XDR.Type.BoolTest do
  use ExUnit.Case
  alias XDR.Type.Bool
  alias XDR.Type.Int
  doctest XDR.Type.Bool

  test "is_valid?" do
    assert Bool.is_valid?(true) == true
    assert Bool.is_valid?(false) == true

    assert Bool.is_valid?(nil) == false
    assert Bool.is_valid?(0) == false
    assert Bool.is_valid?("0") == false
    assert Bool.is_valid?([]) == false
    assert Bool.is_valid?({}) == false
  end

  test "encode" do
    assert Bool.encode(false) == Int.encode(0)
    assert Bool.encode(true) == Int.encode(1)

    assert Bool.encode(nil) == {:error, :invalid}
  end

  test "decode" do
    assert Int.decode(0) == Bool.decode(false)
    assert Int.decode(1) == Bool.decode(true)

    assert Int.decode(2) == {:error, :invalid}
  end
end
