defmodule XDR.Type.UnionTest do
  use ExUnit.Case
  alias XDR.Type.Union
  alias XDR.Type.Enum
  alias XDR.Type.Int
  alias XDR.Type.Void

  defmodule XDR.Type.UnionTest.ResultEnum do
    use Enum, spec: [
      ok:       0,
      error:    1,
      nonsense: 2,
    ]
  end

  defmodule XDR.Type.UnionTest.Ext do
    use Union, spec: [
      switch: Int,
      cases: [
        {0,   Void},
      ],
    ]
  end

  defmodule XDR.Type.UnionTest.Result do
    require XDR.Type.UnionTest.ResultEnum
    alias XDR.Type.UnionTest.ResultEnum

    use Union, spec: [
      switch:   ResultEnum,
      cases: [
        ok:     Void,
        error:  :code,
      ],
      default:  Void,
      attributes: [
        code: Int,
      ],
    ]
  end

  alias XDR.Type.UnionTest.{ResultEnum, Result, Ext}

  test "new" do
    assert Ext.new(0) == {:ok, 0}
    assert Result.new == {:ok, nil}
    assert Result.new(:ok) == {:ok, :ok}
    assert Result.new({:error, 5}) == {:ok, {:error, 5}}
    assert Result.new(:nonsense) == {:ok, :nonsense}

    assert Ext.new(1) == {:error, :invalid}
    assert Ext.new(-1) == {:error, :invalid}
    assert Result.new(:error) == {:error, :invalid}
    assert Result.new({:nonsense, 2}) == {:error, :invalid}
    assert Result.new(nil) == {:error, :invalid}
    assert Result.new(0) == {:error, :invalid}
    assert Result.new([]) == {:error, :invalid}
    assert Result.new({}) == {:error, :invalid}
    assert Result.new(false) == {:error, :invalid}
  end

  test "valid?" do
    assert Ext.valid?(0) == true
    assert Result.valid?(:ok) == true
    assert Result.valid?({:error, 5}) == true
    assert Result.valid?(:nonsense) == true

    assert Ext.valid?(1) == false
    assert Ext.valid?(-1) == false
    assert Result.valid?(:error) == false
    assert Result.valid?({:nonsense, 2}) == false
    assert Result.valid?(nil) == false
    assert Result.valid?(0) == false
    assert Result.valid?([]) == false
    assert Result.valid?({}) == false
    assert Result.valid?(false) == false
  end

  test "encode" do
    assert Ext.encode(0) == {:ok, <<0, 0, 0, 0>>}
    assert Result.encode(:ok) == {:ok, <<0, 0, 0, 0>>}
    assert Result.encode({:error, 5}) == {:ok, <<0, 0, 0, 1, 0, 0, 0, 5>>}
    assert Result.encode(:nonsense) == {:ok, <<0, 0, 0, 2>>}

    assert Ext.encode(1) == {:error, :invalid}
    assert Ext.encode(-1) == {:error, :invalid}
    assert Result.encode(:error) == {:error, :invalid}
    assert Result.encode({:nonsense, 2}) == {:error, :invalid}
  end

  test "decode" do
    assert Ext.decode(<<0, 0, 0, 0>>) == {:ok, 0}
    assert Result.decode(<<0, 0, 0, 0>>) == {:ok, :ok}
    assert Result.decode(<<0, 0, 0, 1, 0, 0, 0, 5>>) == {:ok, {:error, 5}}
    assert Result.decode(<<0, 0, 0, 2>>) == {:ok, :nonsense}

    assert Ext.decode(<<0, 0, 0, 1>>) == {:error, :invalid}
    assert Result.decode(<<0, 0, 0, 1>>) == {:error, :invalid}
  end
end
