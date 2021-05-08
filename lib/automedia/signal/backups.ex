defmodule Automedia.Signal.Backups do
  @moduledoc false

  @file_module Application.get_env(:automedia, :file_module, File)

  @callback from(Path.t()) :: [Path.t()]
  def from(path) do
    {
      :ok,
      @file_module.ls!(path)
      |> Enum.filter(&is_signal_backup?/1)
      |> Enum.map(&(Path.join(path, &1)))
      |> Enum.sort()
    }
  end

  defp is_signal_backup?(filename) do
    Regex.match?(~r<\Asignal-[-\d]+\.backup\z>, filename)
  end
end
