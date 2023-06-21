defmodule Automedia.WhatsApp.MovableTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    ls_result = Map.get(context, :ls_result, [])
    stub(MockFile, :ls!, fn "/path" -> ls_result end)

    :ok
  end

  @tag ls_result: ["foo", "IMG-20160501-WA9999.jpeg"]
  test "it returns IMG_ files" do
    assert Automedia.WhatsApp.Movable.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "jpeg",
          source: "/path/IMG-20160501-WA9999.jpeg",
          time: nil
        }
      ]
    }
  end

  @tag ls_result: ["IMG-20160501-WA9999.jpg", "IMG-99999999-WA9999.jpg"]
  test "when dates are incorrect, it skips them" do
    assert Automedia.WhatsApp.Movable.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "jpg",
          source: "/path/IMG-20160501-WA9999.jpg",
          time: nil
        }
      ]
    }
  end

  @tag ls_result: ["foo", "VID-20190206-WA0020.mp4"]
  test "it returns VID_ files" do
    assert Automedia.WhatsApp.Movable.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2019-02-06],
          destination: nil,
          extension: "mp4",
          source: "/path/VID-20190206-WA0020.mp4",
          time: nil
        }
      ]
    }
  end
end
