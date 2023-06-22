defmodule Automedia.Signal.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "without parameters, it fails" do
    result = Automedia.Signal.CLI.run([])

    assert result == 1
  end

  test "without an unknown command, it fails" do
    result = Automedia.Signal.CLI.run(~w(foo))

    assert result == 1
  end

  test "without required parameters, clean fails" do
    result = Automedia.Signal.CLI.run(~w(clean --foo a))

    assert result == 1
  end

  test "without required parameters, move fails" do
    result = Automedia.Signal.CLI.run(~w(move --foo a))

    assert result == 1
  end

  test "without required parameters, unpack fails" do
    result = Automedia.Signal.CLI.run(~w(unpack --foo a))

    assert result == 1
  end

  test "it moves files" do
    expect(Automedia.Signal.MockMove, :run, fn _ -> {:ok} end)

    Automedia.Signal.CLI.run(~w(move --source a --destination b))
  end

  test "it unpacks backups" do
    expect(Automedia.Signal.MockUnpackBackup, :run, fn _ -> {:ok} end)

    Automedia.Signal.CLI.run(["unpack", "--source", "a", "--destination", "b", "--password-file", "p"])
  end
end
