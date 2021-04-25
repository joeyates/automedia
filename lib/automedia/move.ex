defmodule Automedia.Move do
  @moduledoc false

  require Logger

  require Automedia.Movable

  def move(%Automedia.Movable{source: source, destination: destination}, options) do
    dry_run = Keyword.get(options, :dry_run, false)
    path = Path.dirname(destination)
    if !File.dir?(path) do
      Logger.info "Creating directory '#{path}'"
      if !dry_run, do: File.mkdir_p!(path)
    end
    if File.regular?(destination) do
      Logger.info "Skipping move of '#{source}' to '#{destination}' - destination file already exists"
    else
      Logger.info "Moving '#{source}' to '#{destination}'"
      if !dry_run, do: File.rename!(source, destination)
    end
  end
end
