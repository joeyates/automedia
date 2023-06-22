defmodule Automedia.Nextcloud.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Nextcloud.Tag

  @tag_switches [
    database: %{type: :string, required: true},
    database_prefix: %{type: :string, required: true},
    case_sensitive: %{type: :boolean},
    dry_run: %{type: :boolean},
    host: %{type: :string, required: true},
    match: %{type: :string},
    password: %{type: :string, required: true},
    path_prefix: %{type: :string},
    tag: %{type: :string, required: true},
    username: %{type: :string, required: true}
  ]

  @callback run([String.t()]) :: :integer

  def run(["tag" | args]) do
    case Automedia.OptionParser.run(args, switches: @tag_switches) do
      {:ok, options, []} ->
        {:ok} =
          struct!(Tag, options)
          |> Tag.run()
        0
      {:error, message} ->
        IO.puts :stderr, message
        1
    end
  end

  def run(args) do
    IO.puts :stderr, "automedia nextcloud, expected 'tag' command, got #{inspect(args)}"
    1
  end
end
