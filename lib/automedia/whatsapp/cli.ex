defmodule Automedia.WhatsApp.CLI do
  @moduledoc false

  require Logger

  alias Automedia.WhatsApp.Move

  @move_switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    prefix: %{type: :string},
    quiet: %{type: :boolean, required: true},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @whatsapp_move Application.get_env(:automedia, :whatsapp_move, Move)

  @callback run([String.t()]) :: {:ok}
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @move_switches,
          struct: Move
        ) do
      {:ok, options, []} ->
        {:ok} = @whatsapp_move.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
