defmodule Automedia.Move do
  @moduledoc false

  require Automedia.Movable

  def move(%Automedia.Movable{} = movable) do
    path = Path.dirname(movable.destination)
    File.mkdir_p!(path)
    File.rename!(movable.source, movable.destination)
  end
end
