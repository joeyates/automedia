defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans the source path for Android media files and moves them to the directory
  tree under the supplied root according to their creation date.
  """

  require Logger

  alias Automedia.Android.Move

  @switches %{
    destination: %{type: :string, required: true},
    dry_run: %{type: :boolean},
    quiet: %{type: :boolean},
    source: %{type: :string, required: true},
    verbose: %{type: :count}
  }

  @android_move Application.get_env(:automedia, :android_move, Move)

  @callback run([String.t()]) :: {:ok}
  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @switches
        ) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Move, options)
          |> @android_move.run()
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
