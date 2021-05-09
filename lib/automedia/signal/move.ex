defmodule Automedia.Signal.Move do
  require Logger

  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source start_timestamp_file verbose)a

  @destination_chooser Application.get_env(:automedia, :destination_chooser, Automedia.DestinationChooser)
  @move Application.get_env(:automedia, :move, Automedia.Move)
  @signal_movable Application.get_env(:automedia, :signal_movable, Automedia.Signal.Movable)
  @signal_timestamp Application.get_env(:automedia, :signal_timestamp, Automedia.Signal.Timestamp)

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

    {:ok, start} = @signal_timestamp.optionally_read(options)

    with {:ok, movables} <- @signal_movable.find(options.source, from: start),
         movables <- @destination_chooser.run(movables, options.destination),
         {:ok} <- move(movables, options),
         {:ok} <- @signal_timestamp.optionally_write(movables, options) do
      {:ok}
    end
  end

  defp move(movables, options) do
    if length(movables) == 0, do: Logger.debug "No Signal files found"

    Enum.each(movables, &(@move.move(&1, dry_run: options.dry_run)))

    {:ok}
  end
end
