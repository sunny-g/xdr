defmodule XDR.Type.BoolTest do
  use ExUnit.Case
  alias XDR.Type.Bool
  alias XDR.Type.Int
  doctest XDR.Type.Bool

  test "valid?" do
    assert Bool.valid?(true) == true
    assert Bool.valid?(false) == true

    assert Bool.valid?(nil) == false
    assert Bool.valid?(0) == false
    assert Bool.valid?("0") == false
    assert Bool.valid?([]) == false
    assert Bool.valid?({}) == false
  end

  test "encode" do
    assert Bool.encode(false) == Int.encode(0)
    assert Bool.encode(true) == Int.encode(1)

    assert Bool.encode(nil) == {:error, :invalid}
  end

  test "decode" do
    assert Int.encode(0)
      |> elem(1)
      |> Bool.decode == {:ok, false}
    assert Int.encode(1)
      |> elem(1)
      |> Bool.decode == {:ok, true}

    assert Int.decode(2) == {:error, :invalid}
  end
end
