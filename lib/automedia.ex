defmodule Automedia do
  @moduledoc """
  The entry point for the various renaming strategies.
  """

  @android_cli Application.get_env(:automedia, :android_cli, Automedia.Android.CLI)
  @signal_cli Application.get_env(:automedia, :signal_cli, Automedia.Signal.CLI)

  @doc false
  @callback run([String.t()]) :: {:ok}
  def run(["android" | args]) do
    {:ok} = @android_cli.run(args)
  end
  def run(["signal" | args]) do
    {:ok} = @signal_cli.run(args)
  end
end
