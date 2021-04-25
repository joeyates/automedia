defmodule Automedia.Signal.CLI do
  @moduledoc false

  require Logger

  import Automedia.ConversionHelpers, only: [i_or_nil: 1]

  @switches [
    destination: :string,
    dry_run: :boolean,
    start_timestamp_file: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  def run(args) do
    options = Automedia.OptionParser.run(args, @switches, @required)

    if options.dry_run, do: Logger.debug "This is a dry run, nothing will be changed"

    start = start_datetime(options)

    movable =
      options.source
      |> Automedia.Signal.Movable.find(from: start)
      |> Automedia.DestinationChooser.run(options.destination)

    if length(movable) == 0, do: Logger.debug "No Signal files found"

    Enum.map(movable, &(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end

  defp start_datetime(%{start_timestamp_file: pathname}) do
    if File.regular?(pathname) do
      timestamp = File.read!(pathname) |> i_or_nil
      if timestamp do
        dt = DateTime.from_unix!(timestamp)
        Logger.debug "The Signal start timestamp file indicates only Signal files created after #{dt} are to be considered"
      end
      timestamp
    else
      Logger.debug "The Signal start timestamp file does not yet exist - all matching files will be collected"
    end
  end
  defp start_datetime(_options), do: nil
end
