defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans the source path for Android media files and moves them to the directory
  tree under the supplied root according to their creation date.
  """

  alias Automedia.Android.Move

  @switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @android_move Application.compile_env(:automedia, :android_move, Move)

  @callback run([String.t()]) :: :integer
  def run(["help" | ["move" | _args]]) do
    IO.puts "Usage:"
    IO.puts "  automedia android move [OPTIONS]"
    IO.puts Automedia.OptionParser.help(@switches)
    IO.puts "Move Android files to media directories based on date in filename"
    0
  end

  def run(["help" | _args]) do
    IO.puts "Commands:"
    IO.puts "  automedia android move [OPTIONS]"
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
        1
    end
  end

  def run(args) do
    IO.puts :stderr, "automedia android, expected 'move' command, got #{inspect(args)}"
    1
  end
end
