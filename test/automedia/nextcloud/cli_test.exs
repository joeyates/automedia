defmodule Automedia.Nextcloud.CLITest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "without parameters, it fails" do
    result = Automedia.Nextcloud.CLI.run([])

    assert result == 1
  end

  test "without an unknown command, it fails" do
    result = Automedia.Nextcloud.CLI.run(~w(foo))

    assert result == 1
  end

  test "without required parameters, tag fails" do
    result = Automedia.Nextcloud.CLI.run(~w(tag --foo a))

    assert result == 1
  end
end
