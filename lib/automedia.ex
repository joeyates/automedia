defmodule Automedia do
  @moduledoc """
  The entry point for the various renaming strategies.
  """

  @doc false
  def run(["android" | args]) do
    Automedia.Android.CLI.run(args)
  end
  def run(["signal" | args]) do
    Automedia.Signal.CLI.run(args)
  end
end
