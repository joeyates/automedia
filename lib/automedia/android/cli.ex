defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans all source paths for media files and moves them to the directory
  tree under the media root according to their creation date.
  """

  require Logger

  @switches [
    destination: :string,
    dry_run: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @switches,
          required: @required
        ) do
      {:ok, options, []} ->
        move_android_files(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end

  defp move_android_files(options) do
    options.source
    |> Automedia.Android.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end
end
