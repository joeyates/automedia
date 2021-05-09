defmodule Mix.Tasks.Automedia.Run do
  use Mix.Task

  @moduledoc """
  Applies various strategies for file naming
  """
  @shortdoc "Moves files from source paths to media directories"

  @automedia Application.get_env(:automedia, :automedia, Automedia)

  def run(args) do
    {:ok} = @automedia.run(args)
  end
end
