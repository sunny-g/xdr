defmodule XDR.Type.StringTest do
  use ExUnit.Case
  alias XDR.Type.String
  doctest XDR.Type.String

  test "is_valid?" do
    assert String.is_valid?("", 2) == true
    assert String.is_valid?("A", 2) == true
    assert String.is_valid?("AA", 2) == true
    assert String.is_valid?("三", 3) == true

    assert String.is_valid?("AAA", 2) == false
    assert String.is_valid?("三", 2) == false
    assert String.is_valid?(<<0, 0>>, 1) == false
    assert String.is_valid?(<<0, 0, 0>>, 2) == false
    assert String.is_valid?(false, 1) == false
    assert String.is_valid?(nil, 1) == false
    assert String.is_valid?(0, 1) == false
    assert String.is_valid?([0], 1) == false
  end

  test "encode" do
    assert String.encode("", 4) == {:ok, <<0, 0, 0, 0>>}
    assert String.encode("三", 4) == {:ok, <<0, 0, 0, 3, 228, 184, 137, 0>>}
    assert String.encode("A", 4) == {:ok, <<0, 0, 0, 1, 65, 0, 0, 0>>}
    assert String.encode("AA", 4) == {:ok, <<0, 0, 0, 2, 65, 65, 0, 0>>}

    assert String.encode("AAAAA", 4) == {:error, :invalid}
  end

  test "decode" do
    assert String.decode(<<0, 0, 0, 0>>, 4) == {:ok, ""}
    assert String.decode(<<0, 0, 0, 3, 228, 184, 137, 0>>, 4) == {:ok, "三"}
    assert String.decode(<<0, 0, 0, 1, 65, 0, 0, 0>>, 4) == {:ok, "A"}
    assert String.decode(<<0, 0, 0, 2, 65, 65, 0, 0>>, 4) == {:ok, "AA"}

    assert String.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert String.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>, Math.pow(2, 32)) == {:error, :max_length_too_large}
    assert String.decode(<<0, 0, 0, 3, 0, 0, 0, 0>>, 2) == {:error, :xdr_length_exceeds_max}
    assert String.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>, Math.pow(2, 32) - 1) == {:error, :invalid_xdr_length}
    assert String.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert String.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert String.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
