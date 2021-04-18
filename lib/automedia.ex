defmodule Automedia do
  @moduledoc """
  Documentation for `Automedia`.
  """

  @doc false
  def run do
    source_paths =
      System.fetch_env!("SOURCE_PATHS")
      String.split(",")
    destination_path = System.fetch_env!("MEDIA_ROOT")
    movable_files =
      Enum.flat_map(source_paths)
      |> &Automedia.Movable.find/1
  end
end
