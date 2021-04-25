defmodule Mix.Tasks.Automedia.Run do
  use Mix.Task

  @moduledoc """
  Applies various strategies for file naming
  """
  @shortdoc "Moves files from source paths to media directories"

  def run(args) do
    Automedia.run(args)
  end
end
