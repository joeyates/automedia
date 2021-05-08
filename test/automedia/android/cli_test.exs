defmodule Automedia.Android.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it moves files" do
    expect(Automedia.Android.MockMove, :run, fn _ -> {:ok} end)

    Automedia.Android.CLI.run(["--source", "a", "--destination", "b"])
  end

  test "without required parameters, it fails" do
    assert catch_exit(Automedia.Android.CLI.run(["--foo", "a"])) == 1
  end
end
