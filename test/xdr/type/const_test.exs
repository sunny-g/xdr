defmodule XDR.Type.ConstTest do
  use ExUnit.Case
  alias XDR.Type.Const

  defmodule XDR.Type.ConstTest.DummyConst do
    # TODO: why does this require the full module name?
    use Const, spec: [type: XDR.Type.Int, value: 3]
  end

  defmodule XDR.Type.ConstTest.InvalidSpec do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid Const spec: 2 is not a valid Elixir.XDR.Type.String", fn ->
      # TODO: why can't I use Const here?
      use XDR.Type.Const, spec: [type: XDR.Type.String, value: 2]
    end
  end

  alias XDR.Type.ConstTest.DummyConst

  test "length" do
    assert DummyConst.length === 32
  end

  test "new" do
    assert DummyConst.new == {:ok, 3}
    assert DummyConst.new(3) == {:ok, 3}

    assert DummyConst.new(4) == {:error, :invalid}
    assert DummyConst.new("3") == {:error, :invalid}
    assert DummyConst.new(false) == {:error, :invalid}
    assert DummyConst.new(nil) == {:error, :invalid}
    assert DummyConst.new([]) == {:error, :invalid}
    assert DummyConst.new({}) == {:error, :invalid}
  end

  test "valid?" do
    assert DummyConst.valid?(3) == true

    assert DummyConst.valid?("3") == false
    assert DummyConst.valid?(4) == false
  end

  test "encode" do
    assert DummyConst.encode(3) == {:ok, <<0, 0, 0, 3>>}

    assert DummyConst.encode("3") == {:error, :invalid_const}
    assert DummyConst.encode(4) == {:error, :invalid_const}
  end

  test "decode" do
    assert DummyConst.decode(<<0, 0, 0, 3>>) == {:ok, 3}

    assert DummyConst.decode(<<0, 0, 0, 4>>) == {:error, :invalid_const}
  end
end
