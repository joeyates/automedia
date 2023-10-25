defmodule Automedia.Fit.CLI do
  @moduledoc false

  require Logger

  alias Automedia.OptionParser
  alias Automedia.Fit.Convert

  @convert_switches [
    bike_data_convertor_binary: %{type: :string, required: true},
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    force: %{type: :boolean},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  ]

  @fit_convert Application.compile_env(:automedia, :fit_convert, Convert)

  @callback run([String.t()]) :: {:ok}

  def run(["convert" | args]) do
    case OptionParser.run(args, switches: @convert_switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Convert, options)
          |> @fit_convert.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        1
    end
  end

  def run(["help" | ["convert" | _args]]) do
    convert_usage()
    0
  end

  def run(["help" | _args]) do
    usage()
    0
  end

  def run(_args) do
    usage(:stderr)
    1
  end

  defp usage(device \\ :stdio) do
    IO.puts device, "Commands:"
    IO.puts device, "  automedia fit convert [OPTIONS]"
  end

  defp convert_usage(device \\ :stdio) do
    IO.puts device, "Usage:"
    IO.puts device, "  automedia fit convert [OPTIONS]"
    IO.puts device, Automedia.OptionParser.help(@convert_switches)
  end
end
