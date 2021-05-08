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

    movable =
      options.source
      |> @signal_movable.find(from: start)
      |> @destination_chooser.run(options.destination)

    if length(movable) == 0, do: Logger.debug "No Signal files found"

    Enum.each(movable, &(@move.move(&1, dry_run: options.dry_run)))

    @signal_timestamp.optionally_write(movable, options)

    {:ok}
  end
end
