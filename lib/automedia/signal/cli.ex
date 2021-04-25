defmodule Automedia.Signal.CLI do
  @moduledoc false

  @switches [
    destination: :string,
    dry_run: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  def run(args) do
    options = Automedia.OptionParser.run(args, @switches, @required)

    options.source
    |> Automedia.Signal.Movable.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end
end
