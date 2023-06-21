defmodule Automedia.WhatsApp.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "without parameters, it fails" do
    result = Automedia.WhatsApp.CLI.run([])

    assert result == 1
  end

  test "without an unknown command, it fails" do
    result = Automedia.WhatsApp.CLI.run(~w(foo))

    assert result == 1
  end

  test "without required parameters, it fails" do
    result = Automedia.WhatsApp.CLI.run(~w(move --foo a))

    assert result == 1
  end

  test "it moves files" do
    expect(Automedia.WhatsApp.MockMove, :run, fn _ -> {:ok} end)

    Automedia.WhatsApp.CLI.run(~w(move --source a --destination b --prefix c))
  end
end
