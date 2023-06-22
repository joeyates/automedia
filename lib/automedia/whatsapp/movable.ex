defmodule Automedia.WhatsApp.Movable do
  @moduledoc false

  require Logger

  import Automedia.ConversionHelpers, only: [i: 1]

  @with_date_and_second ~r[\/(?:IMG-|VID-)(\d{4})(\d{2})(\d{2})-WA(\d{4})\.(jpe?g|mp4)]i

  @file_module Application.compile_env(:automedia, :file_module, File)

  @callback find(String.t()) :: [Automedia.Movable.t()]

  def find(path) do
    Logger.debug "Scanning '#{path}' for WhatsApp files"

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
    match_with_date_and_second(pathname)
  end

  @spec match_with_date_and_second(Path.t()) :: Automedia.Movable.t() | nil
  defp match_with_date_and_second(pathname) do
    match = Regex.run(
      @with_date_and_second,
      pathname,
      capture: :all_but_first
    )
    if match do
      Logger.debug "'#{pathname}' is an WhatsApp file"
      [year, month, day, _counter, extension] = match
      case Date.new(i(year), i(month), i(day)) do
        {:ok, date} ->
          %Automedia.Movable{
            source: pathname,
            date: date,
            extension: extension
          }
        {:error, :invalid_date} ->
          nil
      end
    end
  end
end
