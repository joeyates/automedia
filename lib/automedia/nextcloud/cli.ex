defmodule Automedia.Nextcloud.CLI do
  @moduledoc false

  require Logger

  alias Automedia.Nextcloud.Tag

  @tag_switches [
    prefix: :string,
    tag: :string,
    host: :string,
    database: :string,
    username: :string,
    password: :string
  ]

  @tag_required ~w(prefix tag host database username password)a

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
