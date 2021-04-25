defmodule Automedia do
  @moduledoc """
  Documentation for `Automedia`.
  """

  @doc false
  def run do
    source_path = System.fetch_env!("SOURCE_PATH")
    destination_root = System.fetch_env!("MEDIA_ROOT")

    source_path
    |> Automedia.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(destination_root)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
