defmodule Automedia.Logger do
  @moduledoc false

  require Logger

  def put_level(value) do
    level =
      case value do
        0 -> :none
        1 -> :info
        _ -> :debug
      end
    Logger.configure([level: level])
    Logger.debug "Logger level set to #{level}"
  end
end
