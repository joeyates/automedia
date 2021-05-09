defmodule Automedia.Signal.Movable do
  @moduledoc false

  require Logger

  import Automedia.ConversionHelpers, only: [i: 1]

  @signal_attachment ~r[
    \/
    (?<milliseconds>\d{13})
    _
    (?<counter>\d+)
    \.
    (?<extension>\w+)
    \z
  ]x

  @file_module Application.get_env(:automedia, :file_module, File)

  @callback find(Path.t(), keyword()) :: [Path.t()]
  @callback find(Path.t()) :: [Path.t()]
  def find(path, options \\ []) do
    start = Keyword.get(options, :from)

    {
      :ok,
      list_files(path)
      |> Enum.map(&(Path.join(path, &1)))
      |> Enum.map(&match/1)
      |> Enum.filter(&(&1))
      |> Enum.filter(&(since(&1, start)))
    }
  end

  defp list_files(path) do
    @file_module.ls!(path)
  end

  @spec match(Path.t()) :: Automedia.Movable.t() | nil
  defp match(pathname) do
    match = Regex.named_captures(@signal_attachment, pathname)
    if match do
      Logger.debug "'#{pathname}' is a movable Signal file"
      %{"milliseconds" => ms, "extension" => ext} = match
      dt = DateTime.from_unix!(i(ms), :millisecond)
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
    filetime = DateTime.to_unix(dt)
    older = filetime < timestamp
    if older do
      Logger.debug "Skipping '#{movable.source}' as it was created before the start time (#{filetime} < #{timestamp})"
    end
    !older
  end
end
