defmodule Automedia.Logger do
  def put_level(value) do
    level =
      case value do
        0 -> :none
        1 -> :info
        _ -> :debug
      end
    Logger.configure([level: level])
  end
end
