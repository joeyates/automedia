defmodule Automedia.Move do
  @moduledoc false

  require Automedia.Movable

  def move(%Automedia.Movable{source: source, destination: destination}) do
    path = Path.dirname(destination)
    if !File.dir?(path) do
      IO.puts "Creating directory '#{path}'"
      File.mkdir_p!(path)
    end
    if File.regular?(destination) do
      IO.puts "Skipping move of '#{source}' to '#{destination}' - destination file already exists"
    else
      IO.puts "Moving '#{source}' to '#{destination}'"
      File.rename!(source, destination)
    end
  end
end
