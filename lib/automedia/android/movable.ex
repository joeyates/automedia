defmodule Automedia.Android.Movable do
  @moduledoc false

  require Logger

  import Automedia.ConversionHelpers, only: [i: 1]

  @with_date_and_second ~r[\/(?:IMG|VID)_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})\.(jpe?g|mp4)]i
  @with_date_and_millisecond ~r[\/(?:PXL)_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})(\d{3})\.((?:MP\.)?jpe?g|mp4)]i

  @file_module Application.get_env(:automedia, :file_module, File)

  @callback find(String.t()) :: [Automedia.Movable.t()]
  def find(path) do
    Logger.debug "Scanning '#{path}' for Android files"

    {
      :ok,
      list_files(path)
      |> Enum.map(&(Path.join(path, &1)))
      |> Enum.map(&match/1)
      |> Enum.filter(&(&1))
    }
  end

  defp list_files(path) do
    @file_module.ls!(path)
  end

  defp match(pathname) do
    match_with_date_and_second(pathname) ||
      match_with_date_and_millisecond(pathname)
  end

  @spec match_with_date_and_second(Path.t()) :: Automedia.Movable.t() | nil
  defp match_with_date_and_second(pathname) do
    match = Regex.run(
      @with_date_and_second,
      pathname,
      capture: :all_but_first
    )
    if match do
      Logger.debug "'#{pathname}' is an Android file"
      [year, month, day, hour, minute, second, extension] = match
      with {:ok, date} <- Date.new(i(year), i(month), i(day)),
           {:ok, time} <- Time.new(i(hour), i(minute), i(second)) do
        %Automedia.Movable{
          source: pathname,
          date: date,
          time: time,
          extension: extension
        }
      else
        {:error, :invalid_date} ->
          nil
        {:error, :invalid_time} ->
          nil
      end
    end
  end

  @spec match_with_date_and_millisecond(Path.t()) :: Automedia.Movable.t() | nil
  defp match_with_date_and_millisecond(pathname) do
    match = Regex.run(
      @with_date_and_millisecond,
      pathname,
      capture: :all_but_first
    )
    if match do
      Logger.debug "'#{pathname}' is an Android file"
      [year, month, day, hour, minute, second, millisecond, extension] = match
      with {:ok, date} <- Date.new(i(year), i(month), i(day)),
           {:ok, time} <- Time.new(i(hour), i(minute), i(second), i(millisecond) * 1000) do
        %Automedia.Movable{
          source: pathname,
          date: date,
          time: time,
          extension: extension
        }
      else
        {:error, :invalid_date} ->
          nil
        {:error, :invalid_time} ->
          nil
      end
    end
  end
end
