defmodule Automedia.OptionParser do
  @moduledoc """
  Parse command arguments, throws an error if
  required arguments are not supplied and sets the logging level
  """

  @doc """
  Returns a map of options
  """
  def run(args, switches, required) do
    {options_list, _rest, _errors} = OptionParser.parse(args, strict: switches)

    options = Enum.into(options_list, %{})

    Enum.each(required, fn key ->
      if !Map.has_key?(options, key) do
        raise "Please supply a `--#{key} <VALUE>` parameter"
      end
    end)

    verbose = Map.get(options, :verbose, 0)
    quiet = Map.get(options, :quiet, false)
    level = if quiet do
      0
    else
      verbose
    end
    Automedia.Logger.put_level(level)

    options
  end
end
