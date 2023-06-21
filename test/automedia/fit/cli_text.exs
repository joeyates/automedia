defmodule Automedia.Fit.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "without parameters, it fails" do
    result = Automedia.Fit.CLI.run([])

    assert result == 1
  end

  test "without an unknown command, it fails" do
    result = Automedia.Fit.CLI.run(~w(foo))

    assert result == 1
  end

  test "without required parameters, clean fails" do
    result = Automedia.Fit.CLI.run(~w(convert --foo a))

    assert result == 1
  end

  test "it converts files" do
    expect(Automedia.Fit.MockConvert, :run, fn _ -> {:ok} end)

    Automedia.Fit.CLI.run(~w(convert --bike-data-convertor-path a --destination b --source c))
  end
end
