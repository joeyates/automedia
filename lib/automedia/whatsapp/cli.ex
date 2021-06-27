defmodule Automedia.WhatsApp.CLI do
  @moduledoc false

  require Logger

  alias Automedia.WhatsApp.Move

  @move_switches [
    destination: :string,
    dry_run: :boolean,
    prefix: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @move_required ~w(destination prefix source)a

  @whatsapp_move Application.get_env(:automedia, :whatsapp_move, Move)

  @callback run([String.t()]) :: {:ok}
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @move_switches,
          required: @move_required,
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
