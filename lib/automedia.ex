defmodule Automedia do
  @moduledoc """
  Documentation for `Automedia`.
  """

  @doc false
  def run do
    source_paths =
      System.fetch_env!("SOURCE_PATHS")
      |> String.split(",")
    _destination_path = System.fetch_env!("MEDIA_ROOT")
    IO.puts "source_paths: #{inspect(source_paths, [pretty: true, width: 0])}"
    movable_files = Enum.flat_map(source_paths, &Automedia.Movable.find/1)
    IO.puts "movable_files: #{inspect(movable_files, [pretty: true, width: 0])}"
  end
end
