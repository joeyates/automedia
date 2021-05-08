defmodule Automedia.Android.CLI do
  @moduledoc """
  Scans the source path for Android media files and moves them to the directory
  tree under the supplied root according to their creation date.
  """

  require Logger

  alias Automedia.Android.Move

  @switches [
    destination: :string,
    dry_run: :boolean,
    quiet: :boolean,
    source: :string,
    verbose: :count
  ]

  @required [:source, :destination]

  @android_move Application.get_env(:automedia, :android_move, Move)

  def run(args) do
    case Automedia.OptionParser.run(
          args,
          switches: @switches,
          required: @required
        ) do
      {:ok, options, []} ->
        struct!(Move, options)
        |> @android_move.run()
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
