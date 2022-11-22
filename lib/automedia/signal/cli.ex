defmodule Automedia.Signal.CLI do
  @moduledoc false

  require Logger

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

  @signal_clean Application.get_env(:automedia, :signal_clean, Clean)
  @signal_move Application.get_env(:automedia, :signal_move, Move)
  @signal_unpack_backup Application.get_env(:automedia, :signal_unpack_backup, UnpackBackup)

  @callback run([String.t()]) :: {:ok}
  def run(["clean" | args]) do
    case Automedia.OptionParser.run(
          args,
          switches: @clean_switches,
          struct: Clean
        ) do
      {:ok, options, []} ->
        {:ok} = @signal_clean.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
  def run(["unpack" | args]) do
    case Automedia.OptionParser.run(
          args,
          switches: @unpack_switches,
          struct: UnpackBackup
        ) do
      {:ok, options, []} ->
        {:ok} = @signal_unpack_backup.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @move_switches,
          struct: Move
        ) do
      {:ok, options, []} ->
        {:ok} = @signal_move.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
