defmodule Automedia.WhatsApp.CLI do
  @moduledoc false

  require Logger

  alias Automedia.WhatsApp.Move

  @move_switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    move_duplicates: %{type: :string},
    prefix: %{type: :string, required: true},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @whatsapp_move Application.compile_env(:automedia, :whatsapp_move, Move)

  @callback run([String.t()]) :: integer()

  def run([]) do
    usage(:stderr)
    1
  end

  def run(["help" | ["move" | _args]]) do
    move_usage()
    0
  end

  def run(["help" | _args]) do
    usage()
    0
  end

  def run(["move" | args]) do
    case Automedia.OptionParser.run(args, switches: @move_switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Move, options)
          |> @whatsapp_move.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        move_usage(:stderr)
        1
    end
  end

  def run(args) do
    IO.puts :stderr, "automedia whats_app, expected 'move' command, got #{inspect(args)}"
    usage(:stderr)
    1
  end

  defp usage(device \\ :stdio) do
    IO.puts device, "Command:"
    IO.puts device, "  automedia whats_app move [OPTIONS]"
  end

  defp move_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia whats_app move [OPTIONS]"
    IO.puts device, Automedia.OptionParser.help(@move_switches)
    IO.puts device, ""
    IO.puts device, "Move WhatsApp files to media directories based on date in filename"
  end
end
