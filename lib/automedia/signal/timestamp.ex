defmodule Automedia.Signal.Timestamp do
  @moduledoc """
  Handles the optional `start_timestamp_file` for Automedia.Signal.Move
  """

  require Logger
  import Automedia.ConversionHelpers, only: [i_or_nil: 1]

  @file_module Application.get_env(:automedia, :file_module, File)

  @doc """
  If present, reads the timestamp file, parses its contents (a UNIX timestamp)
  end returns the result.
  """
  @callback optionally_read(Automedia.Signal.Move.t()) :: {:ok, integer() | nil}
  def optionally_read(%Automedia.Signal.Move{start_timestamp_file: nil}), do: {:ok, nil}
  def optionally_read(%Automedia.Signal.Move{start_timestamp_file: pathname}) do
    if @file_module.regular?(pathname) do
      timestamp = @file_module.read!(pathname) |> i_or_nil
      if timestamp do
        dt = DateTime.from_unix!(timestamp)
        Logger.debug "The Signal start timestamp file indicates only Signal files created after #{dt} are to be considered"
      end
      {:ok, timestamp}
    else
      Logger.debug "The Signal start timestamp file does not yet exist - all matching files will be collected"
      {:ok, nil}
    end
  end

  @callback optionally_write([Automedia.Movable.t()], Automedia.Signal.Move.t()) :: {:ok}
  def optionally_write([], _options), do: {:ok}
  def optionally_write(_movables, %{dry_run: true}), do: {:ok}
  def optionally_write(_movables, %{start_timestamp_file: nil}), do: {:ok}
  def optionally_write(movables, %{start_timestamp_file: pathname}) do
    timestamp =
      movables
      |> Enum.map(&(DateTime.new!(&1.date, &1.time) |> DateTime.to_unix()))
      |> Enum.max()
    @file_module.write!(pathname, Integer.to_string(timestamp))

    {:ok}
  end
end
