defmodule Automedia.Signal.CLI do
  @moduledoc false

  import Automedia.ConversionHelpers, only: [i_or_nil: 1]

  @switches [
    destination: :string,
    dry_run: :boolean,
    start_timestamp_file: :string,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  def run(args) do
    options = Automedia.OptionParser.run(args, @switches, @required)

    start = start_datetime(options)

    options.source
    |> Automedia.Signal.Movable.find(from: start)
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end

  defp start_datetime(options) do
    if options.start_timestamp_file do
      if File.regular?(options.start_timestamp_file) do
        File.read!(options.start_timestamp_file) |> i_or_nil
      end
    else
      nil
    end
  end
end
