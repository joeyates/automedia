defmodule Automedia.DestinationChooser do
  @moduledoc false

  def run(movable_files, destination_root) do
    Enum.map(movable_files, &(choose(&1, destination_root)))
  end

  @spec choose(Automedia.Movable.t(), binary) :: Automedia.Movable.t()
  defp choose(
    %Automedia.Movable{
      date: date,
      time: time,
      extension: extension
    } = movable,
    destination_root
  ) do
    year_part = :io_lib.format("~4..0B", [date.year]) |> IO.chardata_to_string()
    month_part = :io_lib.format("~s~2..0B", [year_part, date.month]) |> IO.chardata_to_string()
    day_part = :io_lib.format("~s~2..0B", [month_part, date.day]) |> IO.chardata_to_string()
    name = time_name(time)
    filename = "#{name}.#{extension}"
    destination = Path.join([
      destination_root,
      decade(date.year),
      year_part,
      month_part,
      day_part,
      filename
    ])
    struct(movable, destination: destination)
  end
  defp choose(%Automedia.Movable{} = movable, _destination_root), do: movable

  defp time_name(%Time{hour: h, minute: m, second: s, microsecond: 0}) do
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
