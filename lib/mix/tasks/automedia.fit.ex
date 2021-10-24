defmodule Mix.Tasks.Automedia.Fit do
  @moduledoc """
  Convert FIT files to GPX
  """

  use Mix.Task

  @fit_cli Application.get_env(:automedia, :fit_cli, Automedia.Fit.CLI)

  @shortdoc "Converts .fit files to .gpx"
  @callback run([String.t()]) :: {:ok}
  def run(args) do
    {:ok} = @fit_cli.run(args)
  end
end
