defmodule Automedia.Nextcloud.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Nextcloud.Tag

  @tag_switches [
    database: :string,
    database_prefix: :string,
    dry_run: :boolean,
    host: :string,
    match: :string,
    password: :string,
    path_prefix: :string,
    tag: :string,
    username: :string
  ]

  @tag_required ~w(database_prefix tag host database username password)a

  @callback run([String.t()]) :: {:ok}
  def run(["tag" | args]) do
    case Automedia.OptionParser.run(
          args,
          switches: @tag_switches,
          required: @tag_required,
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
