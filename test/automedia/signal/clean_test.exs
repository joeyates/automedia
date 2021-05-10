defmodule Automedia.Signal.CleanTest do
  use ExUnit.Case, async: true
  import Mox

  alias Automedia.Signal.Clean

  setup :verify_on_exit!

  setup do
    stub(Automedia.Signal.MockBackups, :from, fn _ -> ["/backup/1", "/backup/2"] end)

    :ok
  end

  test "it deletes all but the latest backup" do
    expect(MockFile, :rm!, fn "/backup/1" -> :ok end)

    Clean.run(%Clean{source: "/backups/path"})
  end
end
