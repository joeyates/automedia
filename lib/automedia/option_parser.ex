defmodule Automedia.OptionParser do
  @moduledoc """
  A project-specific command-line option parser
  """

  @doc ~S"""
  Parses command arguments, returns an error if
  required arguments are not supplied and sets the logging level

    iex> Automedia.OptionParser.run(["--foo", "hi"], switches: [foo: :string])
    {:ok, %{foo: "hi"}, []}

    iex> Automedia.OptionParser.run(["-f", "hi"], switches: [foo: :string], aliases: [f: :foo])
    {:ok, %{foo: "hi"}, []}

    iex> Automedia.OptionParser.run(["--bar", "hi"], switches: [foo: :string])
    {:error, "Unexpected parameters supplied: [\"--bar\"]"}

    iex> Automedia.OptionParser.run(["non-switch"], remaining: 1)
    {:ok, %{}, ["non-switch"]}

    iex> Automedia.OptionParser.run(["pizza"])
    {:error, "You supplied unexpected non-switch arguments [\"pizza\"]"}

    iex> Automedia.OptionParser.run(["first", "second"], remaining: 2..3)
    {:ok, %{}, ["first", "second"]}

    iex> Automedia.OptionParser.run(["first"], remaining: 2)
    {:error, "Supply 2 non-switch arguments"}

    iex> Automedia.OptionParser.run(["first"], remaining: 2..3)
    {:error, "Supply 2..3 non-switch arguments"}
  """
  def run(args, options \\ []) do
    with {:ok, opts} <- options_map(options),
         {:ok, named, remaining} <- parse(args, opts),
         {:ok} <- check_required(named, opts),
         {:ok} <- check_remaining(remaining, opts),
         {:ok} <- setup_logger(named) do
      {:ok, named, remaining}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  defp options_map(options), do: {:ok, Enum.into(options, %{})}

  defp parse(args, opts) do
    aliases = opts[:aliases] || []
    switches = opts[:switches] || []

    case OptionParser.parse(args, aliases: aliases, strict: switches) do
      {named_list, remaining, []} ->
        named = Enum.into(named_list, %{})
        {:ok, named, remaining}
      {_, _, invalid} ->
        keys = Enum.map(invalid, fn {key, _value} -> key end)
        {:error, "Unexpected parameters supplied: #{inspect(keys)}"}
    end
  end

  defp check_required(named, opts) do
    required = opts[:required] || []

    missing = Enum.filter(required, &(!Map.has_key?(named, &1)))
    if length(missing) == 0 do
      {:ok}
    else
      {:error, "Please supply the following parameters: #{inspect(missing)}"}
    end
  end

  defp check_remaining(remaining, %{remaining: %Range{} = range}) do
    if length(remaining) in range do
      {:ok}
    else
      {:error, "Supply #{inspect(range)} non-switch arguments"}
    end
  end
  defp check_remaining(remaining, %{remaining: count})
  when length(remaining) == count, do: {:ok}
  defp check_remaining(_remaining, %{remaining: count}) do
    {:error, "Supply #{count} non-switch arguments"}
  end
  defp check_remaining([], _options), do: {:ok}
  defp check_remaining(remaining, _opts) do
    {:error, "You supplied unexpected non-switch arguments #{inspect(remaining)}"}
  end

  defp setup_logger(named) do
    verbose = Map.get(named, :verbose, 1)
    quiet = Map.get(named, :quiet, false)

    level = if quiet do
      0
    else
      verbose
    end
    Automedia.Logger.put_level(level)

    {:ok}
  end
end
