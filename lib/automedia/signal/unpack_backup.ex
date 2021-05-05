defmodule Automedia.Signal.UnpackBackup do
  @enforce_keys ~w(destination password_file source)a
  defstruct ~w(destination dry_run latest password_file quiet source verbose)a

  require Logger

  def run(%__MODULE__{} = options) do
    with {:ok, options} <- choose_latest_backup(options),
         {:ok} <- check_password_file(options),
         {:ok} <- ensure_destination_directory(options) do
       if !options.dry_run, do: unpack(options)
    else
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end

  defp choose_latest_backup(options) do
    case Automedia.Signal.Backups.from(options.source) do
      [] ->
        {:error, "No Signal backups found in '#{options.source}'"}
      backups ->
        latest = backups |> Enum.reverse |> hd()
        pathname = Path.join(options.source, latest)
        {
          :ok,
          struct!(options, latest: pathname)
        }
    end
  end

  defp check_password_file(options) do
    if File.regular?(options.password_file) do
      {:ok}
    else
      {:error, "No password file found at #{options.password_file}"}
    end
  end

  defp ensure_destination_directory(options) do
    if File.dir?(options.destination) do
      Logger.debug "Deleting existing directory '#{options.destination}'"
      if !options.dry_run, do: File.rm_rf!(options.destination)
    end

    Logger.debug "Creating directory '#{options.destination}'"
    if !options.dry_run, do: File.mkdir_p!(options.destination)

    {:ok}
  end

  defp unpack(options) do
    System.cmd(
      "signal-backup-decode",
      [
        "--verbosity", "INFO",
        "--output-path", options.destination,
        "--password-file", options.password_file,
        options.latest
      ]
    )
  end
end
