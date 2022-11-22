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

  @callback run([String.t()]) :: {:ok}
  def run(["tag" | args]) do
    case Automedia.OptionParser.run(
          args,
          switches: @tag_switches,
          struct: Tag
        ) do
      {:ok, options, []} ->
        {:ok} = Tag.run(options)
      {:error, message} ->
        Logger.error message
        exit(1)
    end
  end
end
