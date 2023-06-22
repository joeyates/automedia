defmodule Automedia.Signal.CLI do
  @moduledoc false

  alias Automedia.Signal.Clean
  alias Automedia.Signal.Move
  alias Automedia.Signal.UnpackBackup

  @clean_switches [
    dry_run: %{type: :boolean},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @move_switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    start_timestamp_file: %{type: :string},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @unpack_switches [
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    password_file: %{type: :string, required: true},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @signal_clean Application.compile_env(:automedia, :signal_clean, Clean)
  @signal_move Application.compile_env(:automedia, :signal_move, Move)
  @signal_unpack_backup Application.compile_env(:automedia, :signal_unpack_backup, UnpackBackup)

  @callback run([String.t()]) :: :integer
  def run(["clean" | args]) do
    case Automedia.OptionParser.run(args, switches: @clean_switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Clean, options)
          |> @signal_clean.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        1
    end
  end

  def run(["help" | ["clean" | _args]]) do
    clean_usage()
    IO.puts "..."
    0
  end

  def run(["help" | ["move" | _args]]) do
    move_usage()
    IO.puts "..."
    0
  end

  def run(["help" | ["unpack" | _args]]) do
    unpack_usage()
    IO.puts "..."
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
          |> @signal_move.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        1
    end
  end

  def run(["unpack" | args]) do
    case Automedia.OptionParser.run(args, switches: @unpack_switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(UnpackBackup, options)
          |> @signal_unpack_backup.run()
      {:error, message} ->
        IO.puts :stderr, message
        1
    end
  end

  def run(_args) do
    usage(:stderr)
    1
  end

  defp usage(device \\ :stdio) do
    IO.puts device, "Commands:"
    IO.puts device, "  automedia signal clean|move|unpack [OPTIONS]"
  end

  defp clean_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia signal clean [OPTIONS]"
    IO.puts device, Automedia.OptionParser.help(@clean_switches)
  end

  defp move_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia signal move [OPTIONS]"
    IO.puts device, Automedia.OptionParser.help(@move_switches)
  end

  defp unpack_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia unpack [OPTIONS]"
    IO.puts device, Automedia.OptionParser.help(@unpack_switches)
  end
end
