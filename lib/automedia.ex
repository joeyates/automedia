defmodule Automedia do
  @moduledoc """
  Documentation for `Automedia`.
  """

  @doc false
  def run do
    source_paths =
      System.fetch_env!("SOURCE_PATHS")
      |> String.split(",")
    destination_root = System.fetch_env!("MEDIA_ROOT")

    source_paths
    |> Enum.flat_map(&Automedia.FilenamesWithDate.find/1)
    |> Automedia.DestinationChooser.run(destination_root)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
