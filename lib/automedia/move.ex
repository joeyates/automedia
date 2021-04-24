defmodule Automedia.Move do
  @moduledoc false

  require Automedia.Movable

  def move(%Automedia.Movable{source: source, destination: destination}) do
    path = Path.dirname(destination)
    if !File.dir?(path) do
      File.mkdir_p!(path)
    end
    File.rename!(source, destination)
  end
end
