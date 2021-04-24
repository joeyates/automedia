defmodule Automedia.FilenamesWithDate do
  @moduledoc false

  @with_date_and_time ~r[\/(?:IMG|VID)_(\d{4})(\d{2})(\d{2})_(\d{6})\.(jpe?g|mp4)]

  def find(path) do
    list_files(path)
    |> Enum.map(&(Path.join(path, &1)))
    |> Enum.map(&match/1)
    |> Enum.filter(&(&1))
  end

  defp list_files(path) do
    File.ls!(path)
  end

  defp match(pathname) do
    match_with_date_and_time(pathname)
  end

  @spec match_with_date_and_time(Automedia.Movable.t()) :: Automedia.Movable.t() | nil
  defp match_with_date_and_time(pathname) do
    match = Regex.run(
      @with_date_and_time,
      pathname,
      capture: :all_but_first
    )
    if match do
      [year, month, day, time, extension] = match
      %Automedia.Movable{
        source: pathname,
        year: String.to_integer(year),
        month: String.to_integer(month),
        day: String.to_integer(day),
        time: time,
        extension: extension
      }
    end
  end
end
