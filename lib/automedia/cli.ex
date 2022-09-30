defmodule Automedia.CLI do
  use Bakeware.Script

  @impl Bakeware.Script
  def main(args) do
    IO.inspect(args)
    0
  end
end
