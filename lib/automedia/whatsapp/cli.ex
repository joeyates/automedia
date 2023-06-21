defmodule Automedia.WhatsApp.CLI do
  @moduledoc false

  require Logger

  alias Automedia.WhatsApp.Move

  @move_switches %{
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    prefix: %{type: :string, required: true},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  }

  @whatsapp_move Application.compile_env(:automedia, :whatsapp_move, Move)

  @callback run([]) :: :integer
  def run([]) do
    usage()
    1
  end

  @callback run([String.t()]) :: :integer
  def run(["help" | ["move" | _args]]) do
    IO.puts "Usage:"
    IO.puts "  automedia whats_app move [OPTIONS]"
    IO.puts Automedia.OptionParser.help(@move_switches)
    IO.puts "Move WhatsApp files to media directories based on date in filename"
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
        IO.puts message
        1
    end
  end

  def run(args) do
    IO.puts("automedia whats_app, expected 'move' command, got #{inspect(args)}")
    1
  end

  defp usage do
    IO.puts "Commands:"
    IO.puts "  automedia whats_app move [OPTIONS]"
  end
end
