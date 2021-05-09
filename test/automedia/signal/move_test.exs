defmodule Automedia.Signal.MoveTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    dry_run = Map.get(context, :dry_run, false)

    movable = %Automedia.Movable{date: nil, extension: nil, source: nil}

    stub(Automedia.MockDestinationChooser, :run, fn _, _ -> [movable] end)
    stub(Automedia.Signal.MockMovable, :find, fn _, _ -> {:ok, [movable]} end)
    stub(Automedia.Signal.MockTimestamp, :optionally_read, fn _ -> {:ok, 12345} end)
    stub(Automedia.Signal.MockTimestamp, :optionally_write, fn _, _ -> {:ok} end)

    options = %Automedia.Signal.Move{
      destination: nil,
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
