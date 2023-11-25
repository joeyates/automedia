defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans the source path for Android media files and moves them to the directory
  tree under the supplied root according to their creation date.
  """

  alias Automedia.Android.Move

  @switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    move_duplicates: %{type: :string},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @android_move Application.compile_env(:automedia, :android_move, Move)

  @callback run([String.t()]) :: integer()

  def run(["help" | ["move" | _args]]) do
    move_usage()
    0
  end

  def run(["help" | _args]) do
    usage()
    0
  end

  def run(["move" | args]) do
    case Automedia.OptionParser.run(args, switches: @switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Move, options)
          |> @android_move.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        move_usage(:stderr)
        1
    end
  end

  def run(args) do
    IO.puts :stderr, "automedia android, expected 'help' or 'move' command, got #{inspect(args)}"
    usage(:stderr)
    1
  end

  defp usage(device \\ :stdio) do
    IO.puts device, "Commands:"
    IO.puts device, "  automedia android help|move [OPTIONS]"
  end

  defp move_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia android move [OPTIONS]"
    IO.puts device, ""
    IO.puts device, "Move Android files to media directories based on date in filename"
    IO.puts device, ""
    IO.puts device, Automedia.OptionParser.help(@switches)
  end
end
