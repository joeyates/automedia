defmodule Automedia.CLI do
  use Bakeware.Script

  @impl Bakeware.Script
  def main([]) do
    IO.puts(:stderr, "Please supply a command")
    list_top_level_commands()
    1
  end

  def main([command | args]) do
    case command do
      "android" ->
        run(args)
      "help" ->
        list_top_level_commands()
        0
      _ ->
        IO.puts(:stderr, "Unknown command: '#{command}'")
        1
    end
  end

  defp list_top_level_commands do
    IO.puts("automedia android|fit|nextcloud|signal|whats_app ARGS")
  end

  defp run(args) do
    try do
      Automedia.Android.CLI.run(args)
    rescue e in
      ArgumentError ->
        message = "Automedia Error: #{e.message}"
        IO.puts(:stderr, message)
        1
    end
  end
end
