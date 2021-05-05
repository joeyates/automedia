defmodule Automedia.Signal.Backups do
  @moduledoc false

  def from(path) do
    File.ls!(path)
    |> Enum.filter(&is_signal_backup?/1)
    |> Enum.sort()
  end

  defp is_signal_backup?(filename) do
    Regex.match?(~r<\Asignal-[-\d]+\.backup\z>, filename)
  end
end
