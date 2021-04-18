defmodule Automedia.Move do
  require Automedia.Movable

  def move(%Automedia.Movable{} = movable) do
    path = Path.dirname(movable.destination)
    File.mkdir_p!(path)
    File.rename!(movable.source, movable.destination)
  end
end
