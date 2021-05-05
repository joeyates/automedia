defmodule Automedia.OptionParser do
  @moduledoc """
  Parses command arguments, returns an error if
  required arguments are not supplied and sets the logging level
  """

  @doc false
  def run(args, options \\ []) do
    with {:ok, switches, remaining} <- parse(args, options),
         {:ok} <- check_required(switches, options),
         {:ok} <- check_remaining(remaining, options),
         {:ok} <- setup_logger(switches) do
      {:ok, switches, remaining}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  defp parse(args, options) do
    aliases = Keyword.get(options, :aliases, [])
    switches = Keyword.get(options, :switches, [])

    case OptionParser.parse(args, aliases: aliases, strict: switches) do
      {named_list, remaining, []} ->
        named = Enum.into(named_list, %{})
        {:ok, named, remaining}
      {_, _, invalid} ->
        keys = Enum.map(invalid, fn {key, _value} -> key end)
        {:error, "Unexpected parameters supplied: #{inspect(keys)}"}
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

  defp check_remaining(_remaining, remaining: nil), do: {:ok}
  defp check_remaining(remaining, remaining: count)
  when length(remaining) == count do
    {:ok}
  end
  defp check_remaining(_remaining, remaining: count) do
    {:error, "Supply #{count} non-switch arguments"}
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
