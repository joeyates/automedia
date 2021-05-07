defmodule Automedia.Signal.Move do
  require Logger

  import Automedia.ConversionHelpers, only: [i_or_nil: 1]

  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source start_timestamp_file verbose)a

  def run(%__MODULE__{} = options) do
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

  defp start_datetime(%{start_timestamp_file: nil}), do: nil
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
      nil
    end
  end

  def optionally_update_start_timestamp_file(_options, []), do: nil
  def optionally_update_start_timestamp_file(%{dry_run: true}, _movable), do: nil
  def optionally_update_start_timestamp_file(_movable, %{start_timestamp_file: nil}), do: nil
  def optionally_update_start_timestamp_file(%{start_timestamp_file: pathname}, movable) do
    timestamp =
      movable
      |> Enum.map(&(DateTime.new!(&1.date, &1.time) |> DateTime.to_unix()))
      |> Enum.max()
    File.write!(pathname, Integer.to_string(timestamp))
  end
end
