defmodule Automedia.Signal.MoveTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    destination_path = "/destination/path"
    timestamp_path = "/path/to/timestamp"
    timestamp_exists = Map.get(context, :timestamp_exists, false)
    dry_run = Map.get(context, :dry_run, false)
    movable_file = "/movable/file"

    movable = %Automedia.Movable{
      date: nil,
      extension: nil,
      source: movable_file
    }

    stub(MockFile, :regular?, fn ^timestamp_path -> timestamp_exists end)
    stub(Automedia.Signal.MockMovable, :find, fn _, _ -> [movable] end)
    stub(Automedia.MockDestinationChooser, :run, fn _, _ -> [movable] end)

    options = %Automedia.Signal.Move{
      destination: destination_path,
      dry_run: dry_run,
      source: nil
    }

    Map.merge(context, %{movable: movable, options: options})
  end

  test "it moves files", context do
    %{movable: movable, options: options} = context
    expect(Automedia.MockMove, :move, fn ^movable, _ -> {:ok} end)

    Automedia.Signal.Move.run(options)
  end

  @tag dry_run: true
  test "in a dry run, it does not move files", context do
    %{options: options} = context
    expect(Automedia.MockMove, :move, fn _, dry_run: true -> {:ok} end)

    Automedia.Signal.Move.run(options)
  end
end
