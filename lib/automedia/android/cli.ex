defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans all source paths for media files and moves them to the directory
  tree under the media root according to their creation date.
  """

  @switches [
    source: :string,
    destination: :string,
    verbose: :count,
    quiet: :boolean
  ]

  @required [:source, :destination]

  def run(args) do
    options = Automedia.OptionParser.run(args, @switches, @required)

    options.source
    |> Automedia.Android.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
