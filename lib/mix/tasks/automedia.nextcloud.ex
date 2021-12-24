defmodule Mix.Tasks.Automedia.Nextcloud do
  @moduledoc """
  Update the nextcloud database
  """

  use Mix.Task

  @doc false
  @shortdoc "Invokes Nextcloud CLI"
  @callback run([String.t()]) :: {:ok}
  def run(args) do
    Mix.Task.run "app.start"
    {:ok} = Automedia.Nextcloud.CLI.run(args)
  end
end
