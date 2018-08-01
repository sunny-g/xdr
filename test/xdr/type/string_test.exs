defmodule XDR.Type.StringTest do
  @moduledoc false

  use ExUnit.Case, async: true
  require Math
  alias XDR.Type.String

  defmodule XDR.Type.StringTest.Len1 do
    use String, max_len: 1
  end

  defmodule XDR.Type.StringTest.Len2 do
    use String, max_len: 2
  end

  defmodule XDR.Type.StringTest.Len3 do
    use String, max_len: 3
  end

  defmodule XDR.Type.StringTest.Len4 do
    use String, max_len: 4
  end

  defmodule XDR.Type.StringTest.ExceedMax do
    import CompileTimeAssertions

    assert_compile_time_raise(RuntimeError, "max length too large", fn ->
      use XDR.Type.String, max_len: Math.pow(2, 32)
    end)
  end

  alias XDR.Type.StringTest.{Len1, Len2, Len3, Len4}

  test "length" do
    assert Len1.length() === :variable
    assert Len2.length() === :variable
    assert Len3.length() === :variable
    assert Len4.length() === :variable
  end

  test "new" do
    assert Len1.new() === {:ok, ""}
    assert Len1.new("") === {:ok, ""}
    assert Len1.new("a") === {:ok, "a"}
    assert Len2.new("a") === {:ok, "a"}
    assert Len2.new("ab") === {:ok, "ab"}

    assert Len1.new("ab") === {:error, :invalid}
    assert Len2.new("abc") === {:error, :invalid}
    assert Len1.new(0) === {:error, :invalid}
    assert Len1.new(false) === {:error, :invalid}
    assert Len1.new(nil) === {:error, :invalid}
    assert Len1.new([]) === {:error, :invalid}
    assert Len1.new({}) === {:error, :invalid}
  end

  test "valid?" do
    assert Len2.valid?("") == true
    assert Len2.valid?("A") == true
    assert Len2.valid?("AA") == true
    assert Len3.valid?("三") == true

    assert Len2.valid?("AAA") == false
    assert Len2.valid?("三") == false
    assert Len1.valid?(<<0, 0>>) == false
    assert Len2.valid?(<<0, 0, 0>>) == false
    assert Len1.valid?(false) == false
    assert Len1.valid?(nil) == false
    assert Len1.valid?(0) == false
    assert Len1.valid?([0]) == false
  end

  test "encode" do
    assert Len4.encode("") == {:ok, <<0, 0, 0, 0>>}
    assert Len4.encode("三") == {:ok, <<0, 0, 0, 3, 228, 184, 137, 0>>}
    assert Len4.encode("A") == {:ok, <<0, 0, 0, 1, 65, 0, 0, 0>>}
    assert Len4.encode("AA") == {:ok, <<0, 0, 0, 2, 65, 65, 0, 0>>}

    assert Len4.encode("AAAAA") == {:error, :invalid}
  end

  test "decode" do
    assert Len4.decode(<<0, 0, 0, 0>>) == {:ok, {"", <<>>}}
    assert Len4.decode(<<0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, {"", <<0, 0, 0, 0>>}}
    assert Len4.decode(<<0, 0, 0, 3, 228, 184, 137, 0>>) == {:ok, {"三", <<>>}}
    assert Len4.decode(<<0, 0, 0, 1, 65, 0, 0, 0>>) == {:ok, {"A", <<>>}}
    assert Len4.decode(<<0, 0, 0, 2, 65, 65, 0, 0>>) == {:ok, {"AA", <<>>}}

    assert Len4.decode(<<0, 0, 0, 1, 65, 1, 0>>) == {:error, :invalid}

    assert Len4.decode(<<255, 255, 255, 255, 0, 0, 0, 0>>) ==
             {:error, :xdr_length_exceeds_defined_max}

    assert Len4.decode(<<0, 0, 0, 1, 65, 1, 0, 0>>) == {:error, :invalid_padding}
    assert Len4.decode(<<0, 0, 0, 1, 65, 0, 1, 0>>) == {:error, :invalid_padding}
    assert Len4.decode(<<0, 0, 0, 1, 65, 0, 0, 1>>) == {:error, :invalid_padding}
  end
end
