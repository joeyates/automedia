defmodule Mix.Tasks.Automedia.Run do
  use Mix.Task

  @shortdoc "Moves files from source paths to media directories"

  @moduledoc """
  Scans all source paths for media files and moves them to the directory
  tree under the media root according to their creation date.
  """
  def run(_args) do
    Automedia.run()
  end
end
