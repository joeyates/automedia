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
    movable_files = Enum.flat_map(
      source_paths,
      &Automedia.FilenamesWithDate.find/1
    )
    |> Automedia.DestinationChooser.run(destination_root)
    IO.puts "movable_files: #{inspect(movable_files, [pretty: true, width: 0])}"
  end
end
