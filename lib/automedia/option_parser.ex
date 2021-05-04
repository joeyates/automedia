defmodule Automedia.OptionParser do
  @moduledoc """
  Parses command arguments, returns an error if
  required arguments are not supplied and sets the logging level
  """

  @doc false
  def run(args, options \\ []) do
    with {:ok, switches} <- parse(args, options),
         {:ok} <- check_required(switches, options),
         {:ok} <- setup_logger(switches) do
      {:ok, switches}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  defp parse(args, options) do
    switches = Keyword.get(options, :switches, [])

    case OptionParser.parse(args, strict: switches) do
      {switch_list, [], []} ->
        switches = Enum.into(switch_list, %{})
        {:ok, switches}
      {_, remaining, []} ->
        {:error, "Unexpected non-switch parameters supplied: #{inspect(remaining)}"}
      {_, [], invalid} ->
        keys = Enum.map(invalid, fn {key, _value} -> key end)
        {:error, "Unexpected parameters supplied: #{inspect(keys)}"}
      {_, remaining, invalid} ->
        keys = Enum.map(invalid, fn {key, _value} -> key end)
        {
          :error,
          "Unexpected parameters supplied: #{inspect(keys)}, " <>
            "and unexpected non-switch parameters supplied: #{inspect(remaining)}"
        }
    end
  end

  defp check_required(switches, options) do
    required = Keyword.get(options, :required, [])
    missing = Enum.filter(required, &(!Map.has_key?(switches, &1)))
    if length(missing) == 0 do
      {:ok}
    else
      {:error, "Please supply the following parameters: #{inspect(missing)}"}
    end
  end

  defp setup_logger(switches) do
    verbose = Map.get(switches, :verbose, 0)
    quiet = Map.get(switches, :quiet, false)

    level = if quiet do
      0
    else
      verbose
    end
    Automedia.Logger.put_level(level)

    {:ok}
  end
end
