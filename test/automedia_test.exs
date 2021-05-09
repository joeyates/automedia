defmodule AutomediaTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it runs the Android CLI" do
    expect(Automedia.Android.MockCLI, :run, fn _ -> {:ok} end)

    Automedia.run(["android"])
  end

  test "it runs the Signal CLI" do
    expect(Automedia.Signal.MockCLI, :run, fn _ -> {:ok} end)

    Automedia.run(["signal"])
  end
end
