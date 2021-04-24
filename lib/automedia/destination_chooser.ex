defmodule Automedia.DestinationChooser do
  @moduledoc false

  def run(movable_files, destination_root) do
    Enum.map(movable_files, &(choose(&1, destination_root)))
  end

  @spec choose(Automedia.Movable.t(), binary) :: Automedia.Movable.t()
  defp choose(
    %Automedia.Movable{
      year: year,
      month: month,
      day: day,
      time: time,
      extension: extension
    } = movable,
    destination_root
  ) do
    year_part = :io_lib.format("~4..0B", [year]) |> IO.chardata_to_string()
    month_part = :io_lib.format("~s~2..0B", [year_part, month]) |> IO.chardata_to_string()
    day_part = :io_lib.format("~s~2..0B", [month_part, day]) |> IO.chardata_to_string()
    filename = "#{time}.#{extension}"
    destination = Path.join([
      destination_root,
      decade(year),
      year_part,
      month_part,
      day_part,
      filename
    ])
    struct(movable, destination: destination)
  end
  defp choose(%Automedia.Movable{} = movable, _destination_root), do: movable

  defp decade(year) do
    d = floor(year / 10) * 10
    "#{d}s"
  end
end
