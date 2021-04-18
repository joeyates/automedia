defmodule Automedia.Movable.FilenamesWithDate do
  @with_date_and_time ~r[\/(?:IMG|VID)_(\d{4})(\d{2})(\d{2})_(\d{6})(\.(?:jpg|mp4))]

  def find(path) do
    list_files(path)
    |> Enum.map(&(Path.join(path, &1)))
    |> Enum.filter(&match/1)
  end

  defp list_files(path) do
    File.ls!(path)
  end

  defp match(pathname) do
    match_with_date_and_time(pathname)
  end

  defp match_with_date_and_time(pathname) do
    match = Regex.run(
      @with_date_and_time,
      pathname,
      capture: :all_but_first
    )
    if match do
      [year, month, day, time, extension] = match
      %Automedia.Movable{
        pathname: pathname,
        year: year,
        month: month,
        day: day,
        time: time,
        extension: extension
      }
    end
  end
end
