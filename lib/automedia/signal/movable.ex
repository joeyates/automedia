defmodule Automedia.Signal.Movable do
  @moduledoc false

  import Automedia.ConversionHelpers, only: [i: 1]

  @signal_attachment ~r[
    \/
    (?<seconds>\d{10})
    (?<milliseconds>\d{3})
    _
    (?<counter>\d+)
    \.
    (?<extension>\w+)
    \z
  ]x

  def find(path) do
    list_files(path)
    |> Enum.map(&(Path.join(path, &1)))
    |> Enum.map(&match/1)
    |> Enum.filter(&(&1))
  end

  defp list_files(path) do
    File.ls!(path)
  end

  @spec match(Path.t()) :: Automedia.Movable.t() | nil
  defp match(pathname) do
    match = Regex.named_captures(@signal_attachment, pathname)
    if match do
      %{"seconds" => s, "milliseconds" => ms, "extension" => ext} = match
      dt = DateTime.from_unix!(i(s)) |> DateTime.add(i(ms) * 1000, :microsecond)
      time = DateTime.to_time(dt)
      date = DateTime.to_date(dt)
      %Automedia.Movable{
        source: pathname,
        year: date.year,
        month: date.month,
        day: date.day,
        time: time,
        extension: ext
      }
    end
  end
end
