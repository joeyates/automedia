defmodule Automedia.Signal.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Signal.Clean
  alias Automedia.Signal.Move
  alias Automedia.Signal.UnpackBackup

  @clean_switches [
    dry_run: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @clean_required ~w(source)a

  @move_switches [
    destination: :string,
    dry_run: :boolean,
    start_timestamp_file: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @move_required ~w(destination source)a

  @unpack_switches [
    destination: :string,
    dry_run: :boolean,
    password_file: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @unpack_required ~w(destination password_file source)a

  @signal_clean Application.get_env(:automedia, :signal_clean, Clean)
  @signal_move Application.get_env(:automedia, :signal_move, Move)
  @signal_unpack_backup Application.get_env(:automedia, :signal_unpack_backup, UnpackBackup)

  @callback run([String.t()]) :: {:ok}
  def run(["clean" | args]) do
    case Automedia.OptionParser.run(
          args,
          switches: @clean_switches,
          required: @clean_required,
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
          required: @unpack_required,
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
          required: @move_required,
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
