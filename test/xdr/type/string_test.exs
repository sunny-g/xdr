defmodule XDR.Type.StringTest do
  use ExUnit.Case
  alias XDR.Type.String
  doctest XDR.Type.String

  defmodule XDR.Type.StringTest.Len1 do
    use String, len: 1
  end

  defmodule XDR.Type.StringTest.Len2 do
    use String, len: 2
  end

  defmodule XDR.Type.StringTest.Len3 do
    use String, len: 3
  end

  defmodule XDR.Type.StringTest.Len4 do
    use String, len: 4
  end

  defmodule XDR.Type.StringTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "max length too large", fn ->
      use XDR.Type.String, len: Math.pow(2, 32)
    end
  end

  test "valid?" do
    assert XDR.Type.StringTest.Len2.valid?("") == true
    assert XDR.Type.StringTest.Len2.valid?("A") == true
    assert XDR.Type.StringTest.Len2.valid?("AA") == true
    assert XDR.Type.StringTest.Len3.valid?("三") == true

    assert XDR.Type.StringTest.Len2.valid?("AAA") == false
    assert XDR.Type.StringTest.Len2.valid?("三") == false
    assert XDR.Type.StringTest.Len1.valid?(<<0, 0>>) == false
    assert XDR.Type.StringTest.Len2.valid?(<<0, 0, 0>>) == false
    assert XDR.Type.StringTest.Len1.valid?(false) == false
    assert XDR.Type.StringTest.Len1.valid?(nil) == false
    assert XDR.Type.StringTest.Len1.valid?(0) == false
    assert XDR.Type.StringTest.Len1.valid?([0]) == false
  end

  test "encode" do
    assert XDR.Type.StringTest.Len4.encode("") == {:ok, <<0, 0, 0, 0>>}
    assert XDR.Type.StringTest.Len4.encode("三") == {:ok, <<0, 0, 0, 3, 228, 184, 137, 0>>}
    assert XDR.Type.StringTest.Len4.encode("A") == {:ok, <<0, 0, 0, 1, 65, 0, 0, 0>>}
    assert XDR.Type.StringTest.Len4.encode("AA") == {:ok, <<0, 0, 0, 2, 65, 65, 0, 0>>}

    assert XDR.Type.StringTest.Len4.encode("AAAAA") == {:error, :invalid}
  end

  test "decode" do
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 0>>) == {:ok, ""}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 3, 228, 184, 137, 0>>) == {:ok, "三"}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 1, 65, 0, 0, 0>>) == {:ok, "A"}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 2, 65, 65, 0, 0>>) == {:ok, "AA"}

    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}
    assert XDR.Type.StringTest.Len4.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>) == {:error, :xdr_length_exceeds_defined_max}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert XDR.Type.StringTest.Len4.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
