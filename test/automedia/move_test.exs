defmodule Automedia.MoveTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    source = "/path/source.JPG"
    destination = "/path/to/destination.jpg"
    destination_path = Path.dirname(destination)
    destination_dir_exists = Map.get(context, :destination_dir_exists, false)
    destination_file_exists = Map.get(context, :destination_file_exists, false)

    stub(MockFile, :dir?, fn ^destination_path -> destination_dir_exists end)
    stub(MockFile, :mkdir_p!, fn ^destination_path -> nil end)
    stub(MockFile, :regular?, fn ^destination -> destination_file_exists end)
    stub(MockFile, :rename!, fn _path1, _path2 -> :ok end)

    movable = %Automedia.Movable{
      source: source,
      destination: destination,
      date: nil,
      extension: "jpg"
    }

    Map.merge(context, %{destination_path: destination_path, movable: movable})
  end

  test "it creates the destination directory", context do
    %{destination_path: destination_path, movable: movable} = context
    expect(MockFile, :mkdir_p!, fn ^destination_path -> nil end)

    Automedia.Move.move(movable, [])
  end

  @tag destination_dir_exists: true
  test "when the destination directory exists, it doesn't try to create it", %{movable: movable} do
    expect(MockFile, :mkdir_p!, 0, fn _path -> nil end)

    Automedia.Move.move(movable, [])
  end

  @tag destination_dir_exists: true
  test "in a dry run, it doesn't try to create the destination directory", %{movable: movable} do
    expect(MockFile, :mkdir_p!, 0, fn _path -> nil end)

    Automedia.Move.move(movable, dry_run: true)
  end

  test "it moves the file", %{movable: movable} do
    %{source: source, destination: destination} = movable
    expect(MockFile, :rename!, fn ^source, ^destination -> :ok end)

    Automedia.Move.move(movable, [])
  end

  @tag destination_file_exists: true
  test "when the destination file exists, it doesn't move the file", %{movable: movable} do
    expect(MockFile, :rename!, 0, fn _source, _destination -> :ok end)

    Automedia.Move.move(movable, [])
  end

  test "in a dry run, it doesn't move the file", %{movable: movable} do
    expect(MockFile, :rename!, 0, fn _source, _destination -> :ok end)

    Automedia.Move.move(movable, dry_run: true)
  end
end
