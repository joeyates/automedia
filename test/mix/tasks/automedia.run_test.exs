defmodule Mix.Automedia.RunTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it runs Automedia" do
    expect(MockAutomedia, :run, fn ["args"] -> {:ok} end)

    Mix.Tasks.Automedia.Run.run(["args"])
  end
end
