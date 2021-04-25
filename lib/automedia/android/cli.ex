defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans all source paths for media files and moves them to the directory
  tree under the media root according to their creation date.
  """

  @switches [
    source: :string,
    destination: :string,
    verbose: :count,
    quiet: :boolean
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
    verbose = Keyword.get(options, :verbose, 0)
    quiet = Keyword.get(options, :quiet, false)
    if !File.dir?(source) do
      raise "The `--source` parameter '#{source}' is not a directory"
    end
    if !File.dir?(destination) do
      raise "The `--destination` parameter '#{destination}' is not a directory"
    end
    level = if quiet do
      0
    else
      verbose
    end
    Automedia.Logger.put_level(level)

    source
    |> Automedia.Android.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(destination)
    |> Enum.map(&Automedia.Move.move/1)
  end
end
