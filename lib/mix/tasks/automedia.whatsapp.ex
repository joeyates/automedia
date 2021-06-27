defmodule Mix.Tasks.Automedia.WhatsApp do
  @moduledoc """
  Classify WhatsApp media files by creation date
  """

  use Mix.Task

  @whatsapp_cli Application.get_env(:automedia, :whatsapp_cli, Automedia.WhatsApp.CLI)

  @shortdoc "Moves WhatsApp files to media directories based on date in filename"
  @callback run([String.t()]) :: {:ok}
  def run(args) do
    {:ok} = @whatsapp_cli.run(args)
  end
end
