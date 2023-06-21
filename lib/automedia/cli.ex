defmodule Automedia.CLI do
  use Bakeware.Script

  @impl Bakeware.Script
  def main([]) do
    IO.puts :stderr, "Please supply a command"
    list_top_level_commands(:stderr)
    1
  end

  def main([command|args]) do
    try do
      run(command, args)
    rescue e in
      ArgumentError ->
        message = "Automedia Error: #{e.message}"
        IO.puts :stderr, message
        1
    end
  end

  defp list_top_level_commands(device \\ :stdio) do
    IO.puts device, "automedia android|fit|nextcloud|signal|whats_app ARGS"
  end

  defp run("help", _args) do
    list_top_level_commands()
    0
  end

  defp run("android", args) do
    Automedia.Android.CLI.run(args)
  end

  defp run("fit", args) do
    Automedia.Fit.CLI.run(args)
  end

  defp run("nextcloud", args) do
    Automedia.Nextcloud.CLI.run(args)
  end

  defp run("signal", args) do
    Automedia.Signal.CLI.run(args)
  end

  defp run("whats_app", args) do
    Automedia.WhatsApp.CLI.run(args)
  end

  defp run(command, _args) do
    IO.puts :stderr, "Unknown command: '#{command}'"
    1
  end
end
