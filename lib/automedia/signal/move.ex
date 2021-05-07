defmodule Automedia.Signal.Move do
  require Logger

  import Automedia.ConversionHelpers, only: [i_or_nil: 1]

  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source start_timestamp_file verbose)a

  @automedia_destination_chooser Application.get_env(:automedia, :automedia_destination_chooser, Automedia.DestinationChooser)
  @automedia_move Application.get_env(:automedia, :automedia_move, Automedia.Move)
  @automedia_signal_movable Application.get_env(:automedia, :automedia_signal_movable, Automedia.Signal.Movable)
  @file_module Application.get_env(:automedia, :file_module, File)

  @type t :: %__MODULE__{
    destination: Path.t(),
    dry_run: boolean(),
    quiet: boolean(),
    source: Path.t(),
    start_timestamp_file: Path.t(),
    verbose: integer()
  }

  @callback run(__MODULE__.t()) :: {:ok}
  def run(%__MODULE__{} = options) do
    if options.dry_run, do: Logger.debug "This is a dry run, nothing will be changed"

    start = start_datetime(options)

    movable =
      options.source
      |> @automedia_signal_movable.find(from: start)
      |> @automedia_destination_chooser.run(options.destination)

    if length(movable) == 0, do: Logger.debug "No Signal files found"

    Enum.each(movable, &(@automedia_move.move(&1, dry_run: options.dry_run)))

    optionally_update_start_timestamp_file(movable, options)

    {:ok}
  end

  defp start_datetime(%{start_timestamp_file: nil}), do: nil
  defp start_datetime(%{start_timestamp_file: pathname}) do
    if @file_module.regular?(pathname) do
      timestamp = @file_module.read!(pathname) |> i_or_nil
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

  def optionally_update_start_timestamp_file([], _options), do: nil
  def optionally_update_start_timestamp_file(_movable, %{dry_run: true}), do: nil
  def optionally_update_start_timestamp_file(_movable, %{start_timestamp_file: nil}), do: nil
  def optionally_update_start_timestamp_file(movable, %{start_timestamp_file: pathname}) do
    timestamp =
      movable
      |> Enum.map(&(DateTime.new!(&1.date, &1.time) |> DateTime.to_unix()))
      |> Enum.max()
    @file_module.write!(pathname, Integer.to_string(timestamp))
  end
end
