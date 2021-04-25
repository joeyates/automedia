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

    optionally_update_start_timestamp_file(options, movable)
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

  def optionally_update_start_timestamp_file(_options, []), do: nil
  def optionally_update_start_timestamp_file(%{dry_run: true}, _movable), do: nil
  def optionally_update_start_timestamp_file(%{start_timestamp_file: pathname}, movable) do
    latest = Enum.max(movable, fn m1, m2 ->
      cond do
        m1.date < m2.date -> 2
        m1.date > m2.date -> 1
        m1.time < m2.time -> 2
        m1.time > m2.time -> 1
        true              -> 0
      end
    end)
    timestamp = DateTime.new!(latest.date, latest.time, "Etc/UTC") |> DateTime.to_unix()
    File.write!(pathname, Integer.to_string(timestamp))
  end
  def optionally_update_start_timestamp_file(_options, _movable), do: nil
end
