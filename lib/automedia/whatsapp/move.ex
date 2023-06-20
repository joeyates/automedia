defmodule Automedia.WhatsApp.Move do
  require Logger

  @enforce_keys ~w(destination prefix source)a
  defstruct ~w(destination dry_run prefix quiet source verbose)a

  @destination_chooser Application.compile_env(:automedia, :destination_chooser, Automedia.DestinationChooser)
  @move Application.compile_env(:automedia, :move, Automedia.Move)
  @whatsapp_movable Application.compile_env(:automedia, :whatsapp_movable, Automedia.WhatsApp.Movable)

  @type t :: %__MODULE__{
    destination: Path.t(),
    dry_run: boolean(),
    prefix: String.t(),
    quiet: boolean(),
    source: Path.t(),
    verbose: integer()
  }

  @callback run(__MODULE__.t()) :: {:ok}
  def run(%__MODULE__{} = options) do
    if options.dry_run, do: Logger.debug "This is a dry run, nothing will be changed"

    with {:ok, movables} <- @whatsapp_movable.find(options.source),
         movables <- @destination_chooser.run(movables, options.destination, options.prefix),
         {:ok} <- move(movables, options) do
      {:ok}
    end
  end

  defp move(movables, options) do
    if length(movables) == 0, do: Logger.debug "No WhatsApp files found"

    Enum.each(movables, &(@move.move(&1, dry_run: options.dry_run)))

    {:ok}
  end
end
