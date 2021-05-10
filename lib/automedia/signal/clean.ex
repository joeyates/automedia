defmodule Automedia.Signal.Clean do
  @moduledoc false

  @enforce_keys ~w(source)a
  defstruct ~w(dry_run quiet source verbose)a

  @file_module Application.get_env(:automedia, :file_module, File)
  @signal_backups Application.get_env(:automedia, :signal_backups, Automedia.Signal.Backups)

  @callback run(__MODULE__) :: {:ok}
  def run(%__MODULE__{} = options) do
    {:ok, backups} = all_but_latest_backup(options)
    Enum.each(backups, &(@file_module.rm!(&1)))
    {:ok}
  end

  defp all_but_latest_backup(options) do
    case @signal_backups.from(options.source) do
      [] ->
        {:ok, []}
      [_latest] ->
        {:ok, []}
      backups ->
        [_latest | older] = backups |> Enum.reverse()
        {:ok, older}
    end
  end
end
