defmodule Automedia.Signal.Clean do
  @moduledoc false

  require Logger

  @enforce_keys ~w(source)a
  defstruct ~w(dry_run quiet source verbose)a

  @file_module Application.compile_env(:automedia, :file_module, File)
  @signal_backups Application.compile_env(:automedia, :signal_backups, Automedia.Signal.Backups)

  @callback run(__MODULE__) :: {:ok}

  def run(%__MODULE__{} = options) do
    {:ok, backups} = all_but_latest_backup(options)
    Enum.each(backups, fn backup ->
      Logger.info "Deleting '#{backup}'"
      if !options.dry_run do
        @file_module.rm!(backup)
      end
    end)

    {:ok}
  end

  defp all_but_latest_backup(options) do
    case @signal_backups.from(options.source) do
      {:ok, []} ->
        {:ok, []}
      {:ok, [_latest]} ->
        {:ok, []}
      {:ok, backups} ->
        [_latest | older] = Enum.reverse(backups)
        {:ok, older}
    end
  end
end
