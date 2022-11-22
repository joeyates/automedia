defmodule Automedia.Fit.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Fit.Convert

  @convert_switches [
    bike_data_convertor_path: %{type: :string, required: true},
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    force: %{type: :boolean},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @fit_convert Application.get_env(:automedia, :fit_convert, Convert)

  @callback run([String.t()]) :: {:ok}
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @convert_switches,
          struct: Convert
        ) do
      {:ok, options, []} ->
        {:ok} = @fit_convert.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
