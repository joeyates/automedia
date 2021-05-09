defmodule Automedia.Signal.MovableTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    ls_result = Map.get(context, :ls_result, [])
    stub(MockFile, :ls!, fn "/path" -> ls_result end)

    :ok
  end

  @tag ls_result: ["foo", "1234567890123_999.JPEG"]
  test "it lists Signal files" do
    assert Automedia.Signal.Movable.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2009-02-13],
          destination: nil,
          extension: "JPEG",
          source: "/path/1234567890123_999.JPEG",
          time: ~T[23:31:30.123]
        }
      ]
    }
  end

  @tag ls_result: ["1111111111111_999.JPEG", "1234567890123_999.JPEG"]
  test "with a start timestamp, it excludes older Signal files" do
    assert Automedia.Signal.Movable.find("/path", from: 1111111112) == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2009-02-13],
          destination: nil,
          extension: "JPEG",
          source: "/path/1234567890123_999.JPEG",
          time: ~T[23:31:30.123]
        }
      ]
    }
  end
end
