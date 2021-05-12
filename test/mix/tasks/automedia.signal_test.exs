defmodule Mix.Automedia.AndroidTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it runs the Android CLI" do
    expect(Automedia.Android.MockCLI, :run, fn ["args"] -> {:ok} end)

    Mix.Tasks.Automedia.Android.run(["args"])
  end
end
