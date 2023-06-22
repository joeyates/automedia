defmodule Automedia.Android.CLITest do
  use ExUnit.Case, async: true
  import Mox
  import ExUnit.CaptureIO, only: [capture_io: 1, capture_io: 2]

  setup :verify_on_exit!

  test "without parameters, it fails" do
    capture_io(:stderr, fn ->
      result = Automedia.Android.CLI.run([])

      assert result == 1
    end)
  end

  test "without parameters, it lists commands" do
    output = capture_io(:stderr, fn -> Automedia.Android.CLI.run([]) end)

    assert output =~ ~r(Commands:)
  end

  test "without an unknown command, it fails" do
    capture_io(:stderr, fn ->
      result = Automedia.Android.CLI.run(~w(foo))

      assert result == 1
    end)
  end

  test "it outputs help" do
    output = capture_io(fn -> Automedia.Android.CLI.run(~w(help)) end)

    assert output =~ ~r(Commands:)
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

  test "it outputs help about the move command" do
    output = capture_io(fn -> Automedia.Android.CLI.run(~w(help move)) end)

    assert output =~ ~r(Usage:)
  end

  test "without required parameters, move fails" do
    capture_io(:stderr, fn ->
      result = Automedia.Android.CLI.run(~w(move --foo a))

      assert result == 1
    end)
  end

  test "without incorrect parameters, move lists bad parameters" do
    output = capture_io(:stderr, fn -> Automedia.Android.CLI.run(~w(move --foo a)) end)

    assert output =~ ~r(Unexpected.*?--foo)
  end

  test "without required parameters, move outputs usage" do
    output = capture_io(:stderr, fn -> Automedia.Android.CLI.run(~w(move --foo a)) end)

    assert output =~ ~r(Usage:)
  end
end
