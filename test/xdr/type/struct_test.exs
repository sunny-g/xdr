defmodule XDR.Type.StructTest.Range do
  alias XDR.Type.Struct

  use Struct,
    begin: XDR.Type.Int,
    end: XDR.Type.Int,
    inclusive: XDR.Type.Bool
end

# ---------------------------------------------------------------------------#
# example from RFC 4506
# ---------------------------------------------------------------------------#

defmodule XDR.Type.StructTest.Len32 do
  use XDR.Type.String, max_len: 32
end

defmodule XDR.Type.StructTest.Len255 do
  use XDR.Type.String, max_len: 255
end

defmodule XDR.Type.StructTest.Len65535 do
  use XDR.Type.String, max_len: 65_535
end

defmodule XDR.Type.StructTest.FileKind do
  use XDR.Type.Enum, text: 0, data: 1, exec: 2
end

defmodule XDR.Type.StructTest.FileType do
  use XDR.Type.Union,
    switch: XDR.Type.StructTest.FileKind,
    cases: [
      text: XDR.Type.Void,
      data: :creator,
      exec: :interpretor
    ],
    attributes: [
      creator: XDR.Type.StructTest.Len255,
      interpretor: XDR.Type.StructTest.Len255
    ]
end

defmodule XDR.Type.StructTest.File do
  use XDR.Type.Struct,
    filename: XDR.Type.StructTest.Len255,
    filetype: XDR.Type.StructTest.FileType,
    owner: XDR.Type.StructTest.Len32,
    data: XDR.Type.StructTest.Len65535
end

# ---------------------------------------------------------------------------#
# actual tests
# ---------------------------------------------------------------------------#

defmodule XDR.Type.StructTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias XDR.Type.StructTest.Range
  alias XDR.Type.StructTest.File

  @file_struct %File{
    filename: "sillyprog",
    filetype: {:exec, "lisp"},
    owner: "john",
    data: "(quit)"
  }
  @file_binary <<>> <>
                 <<0x00, 0x00, 0x00, 0x09>> <>
                 <<0x73, 0x69, 0x6C, 0x6C>> <>
                 <<0x79, 0x70, 0x72, 0x6F>> <>
                 <<0x67, 0x00, 0x00, 0x00>> <>
                 <<0x00, 0x00, 0x00, 0x02>> <>
                 <<0x00, 0x00, 0x00, 0x04>> <>
                 <<0x6C, 0x69, 0x73, 0x70>> <>
                 <<0x00, 0x00, 0x00, 0x04>> <>
                 <<0x6A, 0x6F, 0x68, 0x6E>> <>
                 <<0x00, 0x00, 0x00, 0x06>> <>
                 <<0x28, 0x71, 0x75, 0x69>> <> <<0x74, 0x29, 0x00, 0x00>>

  test "length" do
    assert Range.length() === :struct
  end

  test "new" do
    assert Range.new(%Range{begin: 5, end: 255, inclusive: true}) ==
             {:ok, %Range{begin: 5, end: 255, inclusive: true}}

    assert Range.new(%Range{}) == {:error, :invalid}
    assert Range.new(%{begin: 5, end: 255, inclusive: true}) == {:error, :invalid}
    assert Range.new(%{}) == {:error, :invalid}
    assert Range.new(nil) == {:error, :invalid}
    assert Range.new(true) == {:error, :invalid}
    assert Range.new(0) == {:error, :invalid}
    assert Range.new("[]") == {:error, :invalid}
    assert Range.new([]) == {:error, :invalid}
    assert Range.new({}) == {:error, :invalid}
  end

  test "valid?" do
    assert Range.valid?(%Range{begin: 5, end: 255, inclusive: true}) == true

    assert Range.valid?(%Range{}) == false
    assert Range.valid?(%{begin: 5, end: 255, inclusive: true}) == false
    assert Range.valid?(%{}) == false
    assert Range.valid?(nil) == false
    assert Range.valid?(true) == false
    assert Range.valid?(0) == false
    assert Range.valid?("[]") == false
    assert Range.valid?([]) == false
    assert Range.valid?({}) == false
  end

  test "encode" do
    empty_range = %Range{begin: 0, end: 0, inclusive: false}
    filled_range = %Range{begin: 5, end: 255, inclusive: true}

    assert Range.encode(empty_range) == {:ok, <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>}
    assert Range.encode(filled_range) == {:ok, <<0, 0, 0, 5, 0, 0, 0, 255, 0, 0, 0, 1>>}
    assert File.encode(@file_struct) == {:ok, @file_binary}
  end

  test "decode" do
    empty_range = %Range{begin: 0, end: 0, inclusive: false}
    filled_range = %Range{begin: 5, end: 255, inclusive: true}

    assert Range.decode(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == {:ok, {empty_range, <<>>}}
    assert Range.decode(<<0, 0, 0, 5, 0, 0, 0, 255, 0, 0, 0, 1>>) == {:ok, {filled_range, <<>>}}
    assert File.decode(@file_binary) == {:ok, {@file_struct, <<>>}}
    assert File.decode(@file_binary <> <<0, 0, 0, 1>>) == {:ok, {@file_struct, <<0, 0, 0, 1>>}}

    assert Range.decode(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2>>) == {:error, :invalid_enum}
  end
end
