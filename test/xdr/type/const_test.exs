defmodule XDR.Type.ConstTest do
  require Math
  use ExUnit.Case
  alias XDR.Type.Const
  doctest XDR.Type.Const

  defmodule XDR.Type.ConstTest.DummyConst do
    # TODO: why does this require the full module name?
    use Const, [type: XDR.Type.Int, value: 3]
  end

  defmodule XDR.Type.ConstTest.InvalidSpec do
    import CompileTimeAssertions

    assert_compile_time_raise RuntimeError, "invalid Const spec: 2 is not a valid Elixir.XDR.Type.String", fn ->
      # TODO: why can't I use Const here?
      use XDR.Type.Const, [type: XDR.Type.String, value: 2]
    end
  end

  alias XDR.Type.ConstTest.DummyConst

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
