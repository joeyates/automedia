defmodule Automedia.Signal.CLI do
  @moduledoc false

  require Logger

  @move_switches [
    destination: :string,
    dry_run: :boolean,
    start_timestamp_file: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @move_required ~w(destination source)a

  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @move_switches,
          required: @move_required
        ) do
      {:ok, options, []} ->
        Automedia.Signal.Move.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
