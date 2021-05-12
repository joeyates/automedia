defmodule Mix.Tasks.Automedia.Android do
  @moduledoc """
  Classify Android media files by creation date
  """

  use Mix.Task

  @android_cli Application.get_env(:automedia, :android_cli, Automedia.Android.CLI)

  @shortdoc "Moves Android files to media directories based on date in filename"
  @callback run([String.t()]) :: {:ok}
  def run(args) do
    {:ok} = @android_cli.run(args)
  end
end
