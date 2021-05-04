defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans all source paths for media files and moves them to the directory
  tree under the media root according to their creation date.
  """

  @switches [
    destination: :string,
    dry_run: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  def run(args) do
    {:ok, options} = Automedia.OptionParser.run(
      args,
      switches: @switches,
      required: @required
    )

    options.source
    |> Automedia.Android.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end
end
