defmodule Mix.Automedia.WhatsAppTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "it runs the WhatsApp CLI" do
    expect(Automedia.WhatsApp.MockCLI, :run, fn ["args"] -> {:ok} end)

    Mix.Tasks.Automedia.WhatsApp.run(["args"])
  end
end
