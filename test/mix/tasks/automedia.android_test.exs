defmodule Mix.Automedia.SignalTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it runs the Signal CLI" do
    expect(Automedia.Signal.MockCLI, :run, fn ["args"] -> {:ok} end)

    Mix.Tasks.Automedia.Signal.run(["args"])
  end
end
