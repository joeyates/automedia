defmodule Automedia.Android.FilenamesWithDateTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    ls_result = Map.get(context, :ls_result, [])
    stub(MockFile, :ls!, fn "/path" -> ls_result end)

    :ok
  end

  @tag ls_result: ["foo", "IMG_20160501_123403.JPEG"]
  test "it returns IMG_ files" do
    assert Automedia.Android.FilenamesWithDate.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "JPEG",
          source: "/path/IMG_20160501_123403.JPEG",
          time: ~T[12:34:03]
        }
      ]
    }
  end

  @tag ls_result: ["IMG_20160501_123403.JPEG", "IMG_99999999_123403.JPEG"]
  test "when dates are incorrect, it skips them" do
    assert Automedia.Android.FilenamesWithDate.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "JPEG",
          source: "/path/IMG_20160501_123403.JPEG",
          time: ~T[12:34:03]
        }
      ]
    }
  end

  @tag ls_result: ["IMG_20160501_123403.JPEG", "IMG_20160501_999999.JPEG"]
  test "when times are incorrect, it skips them" do
    assert Automedia.Android.FilenamesWithDate.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "JPEG",
          source: "/path/IMG_20160501_123403.JPEG",
          time: ~T[12:34:03]
        }
      ]
    }
  end

  @tag ls_result: ["foo", "VID_20160501_123403.MP4"]
  test "it returns VID_ files" do
    assert Automedia.Android.FilenamesWithDate.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "MP4",
          source: "/path/VID_20160501_123403.MP4",
          time: ~T[12:34:03]
        }
      ]
    }
  end

  @tag ls_result: ["foo", "PXL_20160501_123403123.JPG"]
  test "it returns PXL_ files" do
    assert Automedia.Android.FilenamesWithDate.find("/path") == {
      :ok,
      [
        %Automedia.Movable{
          date: ~D[2016-05-01],
          destination: nil,
          extension: "JPG",
          source: "/path/PXL_20160501_123403123.JPG",
          time: ~T[12:34:03.123000]
        }
      ]
    }
  end
end
