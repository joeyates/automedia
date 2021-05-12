defmodule Mix.Tasks.Automedia.Signal do
  @moduledoc """
  Classify Signal media files by creation date
  """

  use Mix.Task

  @signal_cli Application.get_env(:automedia, :signal_cli, Automedia.Signal.CLI)

  @doc false
  @shortdoc "Invokes Signal CLI"
  @callback run([String.t()]) :: {:ok}
  def run(args) do
    {:ok} = @signal_cli.run(args)
  end
end
