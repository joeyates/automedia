defmodule Automedia.Fit.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Fit.Convert

  @convert_switches [
    bike_data_convertor_path: :string,
    destination: :string,
    dry_run: :boolean,
    force: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @convert_required ~w(bike_data_convertor_path destination source)a

  @fit_convert Application.get_env(:automedia, :fit_convert, Convert)

  @callback run([String.t()]) :: {:ok}
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @convert_switches,
          required: @convert_required,
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
