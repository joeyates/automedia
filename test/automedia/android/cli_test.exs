defmodule Automedia.Android.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "without parameters, it fails" do
    result = Automedia.Android.CLI.run([])

    assert result == 1
  end

  test "without an unknown command, it fails" do
    result = Automedia.Android.CLI.run(~w(foo))

    assert result == 1
  end

  test "without required parameters, it fails" do
    result = Automedia.Android.CLI.run(~w(move --foo a))

    assert result == 1
  end

  test "it moves files" do
    expect(Automedia.Android.MockMove, :run, fn _ -> {:ok} end)

    Automedia.Android.CLI.run(~w(move --source a --destination b))
  end

  test "it succeeds" do
    stub(Automedia.Android.MockMove, :run, fn _ -> {:ok} end)

    result = Automedia.Android.CLI.run(~w(move --source a --destination b))

    assert result == 0
  end
end
