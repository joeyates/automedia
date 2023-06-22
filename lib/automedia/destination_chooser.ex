defmodule Automedia.DestinationChooser do
  @moduledoc """
  Adds a destination path to a list of movables
  """

  @callback run([Automedia.Movable.t()], String.t()) :: [Automedia.Movable.t()]
  @callback run([Automedia.Movable.t()], String.t(), String.t()) :: [Automedia.Movable.t()]
  @doc ~S"""
  Calculates the destination path based on date, time (in seconds) and extension:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: ~D[2020-01-01],
    ...>     extension: "ext",
    ...>     source: nil,
    ...>     time: ~T[15:01:01]
    ...>   }
    ...> ], "/base")
    [
      %Automedia.Movable{
        date: ~D[2020-01-01],
        destination: "/base/2020s/2020/202001/20200101/150101.ext",
        extension: "ext",
        source: nil,
        time: ~T[15:01:01]
      }
    ]

  When the supplied time includes a fractional part, it includes milliseconds:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: ~D[2020-01-01],
    ...>     extension: "ext",
    ...>     source: nil,
    ...>     time: ~T[15:01:01.123]
    ...>   }
    ...> ], "/base")
    [
      %Automedia.Movable{
        date: ~D[2020-01-01],
        destination: "/base/2020s/2020/202001/20200101/150101123.ext",
        extension: "ext",
        source: nil,
        time: ~T[15:01:01.123]
      }
    ]

  When the date is missing, it does not set the destination:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: nil,
    ...>     extension: "ext",
    ...>     source: nil,
    ...>     time: ~T[15:01:01]
    ...>   }
    ...> ], "/base")
    [
      %Automedia.Movable{
        date: nil,
        destination: nil,
        extension: "ext",
        source: nil,
        time: ~T[15:01:01]
      }
    ]

  When the time is missing, it uses the source file name:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: ~D[2020-01-01],
    ...>     extension: "ext",
    ...>     source: "/source/path/filename.ext",
    ...>     time: nil
    ...>   }
    ...> ], "/base")
    [
      %Automedia.Movable{
        date: ~D[2020-01-01],
        destination: "/base/2020s/2020/202001/20200101/filename.ext",
        extension: "ext",
        source: "/source/path/filename.ext",
        time: nil
      }
    ]

  When the extension is missing, it uses the source file name:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: ~D[2020-01-01],
    ...>     extension: nil,
    ...>     source: "/source/path/filename.ext",
    ...>     time: ~T[15:01:01]
    ...>   }
    ...> ], "/base")
    [
      %Automedia.Movable{
        date: ~D[2020-01-01],
        destination: "/base/2020s/2020/202001/20200101/filename.ext",
        extension: nil,
        source: "/source/path/filename.ext",
        time: ~T[15:01:01]
      }
    ]

  When a prefix is supplied, it is added before the file name:

    iex> Automedia.DestinationChooser.run([
    ...>   %Automedia.Movable{
    ...>     date: ~D[2020-01-01],
    ...>     extension: "ext",
    ...>     source: nil,
    ...>     time: ~T[15:01:01]
    ...>   }
    ...> ], "/base", "prefix")
    [
      %Automedia.Movable{
        date: ~D[2020-01-01],
        destination: "/base/2020s/2020/202001/20200101/prefix-150101.ext",
        extension: "ext",
        source: nil,
        time: ~T[15:01:01]
      }
    ]
  """
  def run(movable_files, destination_root, prefix \\ nil) do
    Enum.map(movable_files, &(choose(&1, destination_root, prefix)))
  end

  @spec choose(Automedia.Movable.t(), Pathname.t(), String.t() | nil) :: Automedia.Movable.t()
  defp choose(%Automedia.Movable{date: nil} = movable, _destination_root, _prefix), do: movable
  defp choose(
    %Automedia.Movable{
      date: date,
      source: source,
      time: nil
    } = movable,
    destination_root,
    prefix
  ) do
    directory = date_directory(date, destination_root)
    filename = with_prefix(Path.basename(source), prefix)
    destination = Path.join(directory, filename)
    struct(movable, destination: destination)
  end
  defp choose(
    %Automedia.Movable{
      date: date,
      extension: nil,
      source: source
    } = movable,
    destination_root,
    prefix
  ) do
    directory = date_directory(date, destination_root)
    filename = with_prefix(Path.basename(source), prefix)
    destination = Path.join(directory, filename)
    struct(movable, destination: destination)
  end
  defp choose(
    %Automedia.Movable{
      date: date,
      time: time,
      extension: extension
    } = movable,
    destination_root,
    prefix
  ) do
    directory = date_directory(date, destination_root)
    name = time_name(time)
    filename = with_prefix("#{name}.#{extension}", prefix)
    destination = Path.join(directory, filename)
    struct(movable, destination: destination)
  end

  defp date_directory(%Date{year: year, month: month, day: day}, destination_root) do
    year_part = :io_lib.format("~4..0B", [year]) |> IO.chardata_to_string()
    month_part = :io_lib.format("~s~2..0B", [year_part, month]) |> IO.chardata_to_string()
    day_part = :io_lib.format("~s~2..0B", [month_part, day]) |> IO.chardata_to_string()
    Path.join([
      destination_root,
      decade(year),
      year_part,
      month_part,
      day_part
    ])
  end

  defp with_prefix(filename, nil), do: filename
  defp with_prefix(filename, prefix), do: "#{prefix}-#{filename}"

  defp time_name(%Time{hour: h, minute: m, second: s, microsecond: {0, _precision}}) do
    :io_lib.format("~2..0B~2..0B~2..0B", [h, m, s])
  end
  defp time_name(%Time{hour: h, minute: m, second: s, microsecond: {us, _precision}}) do
    ms = floor(us / 1000)
    :io_lib.format("~2..0B~2..0B~2..0B~3..0B", [h, m, s, ms])
  end

  defp decade(year) do
    d = floor(year / 10) * 10
    "#{d}s"
  end
end
