defmodule Automedia.Signal.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Signal.UnpackBackup
  alias Automedia.Signal.Move

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

  @signal_move Application.get_env(:automedia, :signal_move, Move)
  @signal_unpack_backup Application.get_env(:automedia, :signal_unpack_backup, UnpackBackup)

  @callback run([String.t()]) :: {:ok}
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
