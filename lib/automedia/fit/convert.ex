defmodule Automedia.Fit.Convert do
  @moduledoc false

  @enforce_keys ~w(bike_data_convertor_path destination source)a
  defstruct ~w(bike_data_convertor_path destination dry_run force quiet source verbose)a

  @type t :: %__MODULE__{
    bike_data_convertor_path: Path.t(),
    destination: Path.t(),
    dry_run: boolean(),
    force: boolean(),
    quiet: boolean(),
    source: Path.t(),
    verbose: integer()
  }

  @with_fit_extension ~r[\.fit$]i

  @callback run(__MODULE__.t()) :: {:ok | :error, String.t()}
  def run(%__MODULE__{} = options) do
    with {:ok, fit_files} <- list_fit_files(options.source),
         {:ok, pairs} <- build_destination_paths(fit_files, options.destination),
         {:ok, pairs} <- filter_existing(pairs, options.force) do
      Enum.each(pairs, &(convert(&1, options.bike_data_convertor_path)))
      {:ok}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp list_fit_files(path) do
    files =
      File.ls!(path)
      |> Enum.map(&(Path.join(path, &1)))
      |> Enum.filter(&match_fit_extension/1)
    {:ok, files}
  end

  defp match_fit_extension(pathname) do
    match = Regex.run(
      @with_fit_extension,
      pathname
    )
    !!match
  end

  defp build_destination_paths(paths, destination) do
    pairs =
      Enum.map(
        paths,
        fn path ->
          base = Path.basename(path, ".fit")
          gpx = Path.join(destination, base <> ".gpx")
          {path, gpx}
        end
      )
    {:ok, pairs}
  end

  defp filter_existing(pairs, true), do: {:ok, pairs}
  defp filter_existing(pairs, _force) do
    new =
      Enum.filter(
        pairs,
        fn {_source, destination} -> !File.exists?(destination) end
      )
    {:ok, new}
  end

  defp convert({source, destination}, bike_data_convertor_path) do
    case System.cmd(
          "mix",
          [
            "bike_data_convertor.fit2_gpx",
            "--source", source,
            "--destination", destination
          ],
          cd: bike_data_convertor_path,
          stderr_to_stdout: true
        ) do
      {_output, 0} ->
        {:ok}
      {error, _code} ->
        {:error, "Failed to run bike_data_convertor. Error: #{error}"}
    end
  end
end
