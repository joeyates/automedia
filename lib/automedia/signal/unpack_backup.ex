defmodule Automedia.Signal.UnpackBackup do
  @enforce_keys ~w(destination password_file source)a
  defstruct ~w(destination dry_run latest password_file quiet source verbose)a

  require Logger

  @file_module Application.compile_env(:automedia, :file_module, File)
  @system_module Application.compile_env(:automedia, :system_module, System)
  @signal_backups Application.compile_env(:automedia, :signal_backups, Automedia.Signal.Backups)

  @callback run(__MODULE__) :: {:ok}

  def run(%__MODULE__{} = options) do
    with {:ok, options} <- choose_latest_backup(options),
         {:ok} <- check_password_file(options),
         {:ok} <- ensure_destination_directory(options),
         {:ok} <- unpack(options) do
       {:ok}
    else
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end

  defp choose_latest_backup(options) do
    case @signal_backups.from(options.source) do
      {:ok, []} ->
        {:error, "No Signal backups found in '#{options.source}'"}
      {:ok, backups} ->
        latest = backups |> Enum.reverse |> hd()
        {
          :ok,
          struct!(options, latest: latest)
        }
    end
  end

  defp check_password_file(options) do
    if @file_module.regular?(options.password_file) do
      {:ok}
    else
      {:error, "No password file found at #{options.password_file}"}
    end
  end

  defp ensure_destination_directory(options) do
    if @file_module.dir?(options.destination) do
      Logger.debug "Deleting existing directory '#{options.destination}'"
      if !options.dry_run, do: @file_module.rm_rf!(options.destination)
    end

    Logger.debug "Creating directory '#{options.destination}'"
    if !options.dry_run, do: @file_module.mkdir_p!(options.destination)

    {:ok}
  end

  defp unpack(%__MODULE__{dry_run: true}), do: {:ok}
  defp unpack(options) do
    case @system_module.cmd(
          "signal-backup-decode",
          [
            "--verbosity", "INFO",
            "--output-path", options.destination,
            "--password-file", options.password_file,
            options.latest
          ],
          stderr_to_stdout: true
        ) do
      {_output, 0} ->
        {:ok}
      {error, _code} ->
        {:error, "Failed to run signal-backup-decode. Error: #{error}"}
    end
  end
end
