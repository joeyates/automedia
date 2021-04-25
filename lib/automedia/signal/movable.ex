defmodule Automedia.Signal.Movable do
  @moduledoc false

  require Logger

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

  def find(path, [from: start]) do
    list_files(path)
    |> Enum.map(&(Path.join(path, &1)))
    |> Enum.map(&match/1)
    |> Enum.filter(&(&1))
    |> Enum.filter(&(since(&1, start)))
  end

  defp list_files(path) do
    File.ls!(path)
  end

  @spec match(Path.t()) :: Automedia.Movable.t() | nil
  defp match(pathname) do
    match = Regex.named_captures(@signal_attachment, pathname)
    if match do
      Logger.debug "'#{pathname}' is a movable Signal file"
      %{"seconds" => s, "milliseconds" => ms, "extension" => ext} = match
      dt = DateTime.from_unix!(i(s)) |> DateTime.add(i(ms) * 1000, :microsecond)
      time = DateTime.to_time(dt)
      date = DateTime.to_date(dt)
      %Automedia.Movable{
        source: pathname,
        date: date,
        time: time,
        extension: ext
      }
    end
  end

  defp since(movable, nil), do: movable
  defp since(movable, timestamp) do
    dt = DateTime.new!(movable.date, movable.time)
    unix = DateTime.to_unix(dt)
    more_recent = unix > timestamp
    if !more_recent do
      Logger.debug "Skipping '#{movable.source}' as it was created before the start time (#{unix} > #{timestamp})"
    end
    more_recent
  end
end
