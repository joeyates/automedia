defmodule Automedia.Signal.BackupsTest do
  use ExUnit.Case, async: true
  import Mox

  alias Automedia.Signal.Backups

  setup :verify_on_exit!

  setup do
    stub(MockFile, :ls!, fn "/path" -> ["signal-456.backup", "signal-123.backup"] end)

    :ok
  end

  test "it returns a sorted list of Signal backups" do
    assert Backups.from("/path") == {
      :ok,
      ["/path/signal-123.backup", "/path/signal-456.backup"]
    }
  end
end
