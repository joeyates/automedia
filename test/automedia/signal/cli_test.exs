defmodule Automedia.Signal.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it moves files" do
    expect(Automedia.Signal.MockMove, :run, fn _ -> {:ok} end)

    Automedia.Signal.CLI.run(["--source", "a", "--destination", "b"])
  end

  test "without required parameters, it fails" do
    assert catch_exit(Automedia.Signal.CLI.run(["--foo", "a"])) == 1
  end

  test "it unpacks backups" do
    expect(Automedia.Signal.MockUnpackBackup, :run, fn _ -> {:ok} end)

    Automedia.Signal.CLI.run(["unpack", "--source", "a", "--destination", "b", "--password-file", "p"])
  end

  test "without required parameters, unpacking fails" do
    assert catch_exit(Automedia.Signal.CLI.run(["unpack", "--source", "a"])) == 1
  end
end
