defmodule Automedia.Signal.CLI do
  @moduledoc false

  @switches [
    source: :string,
    destination: :string
  ]

  def run(args) do
    {options, _rest, _errors} = OptionParser.parse(args, strict: @switches)
    if !options[:source] do
      raise "Please supply a `--source <PATH>` parameter"
    end
    if !options[:destination] do
      raise "Please supply a `--destination <PATH>` parameter"
    end
    source = Keyword.fetch!(options, :source)
    destination = Keyword.fetch!(options, :destination)
    if !File.dir?(source) do
      raise "The `--source` parameter '#{source}' is not a directory"
    end
    if !File.dir?(destination) do
      raise "The `--destination` parameter '#{destination}' is not a directory"
    end

    source
    |> Automedia.Signal.Movable.find()
    |> Automedia.DestinationChooser.run(destination)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
