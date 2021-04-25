defmodule Automedia.Signal.CLI do
  @moduledoc false

  @switches [
    source: :string,
    destination: :string,
    verbose: :count,
    quiet: :boolean
  ]

  @required [:source, :destination]

  def run(args) do
    options = Automedia.OptionParser.run(args, @switches, @required)

    options.source
    |> Automedia.Signal.Movable.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
