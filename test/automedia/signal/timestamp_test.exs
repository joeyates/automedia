defmodule Automedia.Signal.TimestampTest do
  use ExUnit.Case, async: true
  import Mox

  alias Automedia.Signal.Timestamp

  setup :verify_on_exit!

  setup context do
    movable_count = Map.get(context, :movable_count, 2)
    timestamp_content = Map.get(context, :timestamp_content, "12345")
    timestamp_path = Map.get(context, :timestamp_path, "/path/to/timestamp")
    timestamp_exists = Map.get(context, :timestamp_exists, true)
    dry_run = Map.get(context, :dry_run, false)

    movables = [
      %Automedia.Movable{
        date: Date.new!(1990, 1, 1),
        time: Time.new!(13, 5, 12),
        extension: nil,
        source: "/movable/file/1"
      },
      %Automedia.Movable{
        date: Date.new!(2020, 1, 1),
        time: Time.new!(13, 5, 12),
        extension: nil,
        source: "/movable/file/1"
      }
    ] |> Enum.take(movable_count)

    stub(MockFile, :read!, fn ^timestamp_path -> timestamp_content end)
    stub(MockFile, :regular?, fn ^timestamp_path -> timestamp_exists end)

    options = %Automedia.Signal.Move{
      destination: nil,
      dry_run: dry_run,
      source: nil,
      start_timestamp_file: timestamp_path
    }

    Map.merge(context, %{movables: movables, options: options})
  end

  test "it reads the timestamp", context do
    assert Timestamp.optionally_read(context.options) == {:ok, 12345}
  end

  @tag timestamp_exists: false
  test "when the file doesn't exist, it returns nil", context do
    assert Timestamp.optionally_read(context.options) == {:ok, nil}
  end

  @tag timestamp_path: nil
  test "when no file path is supplied, it returns nil", context do
    assert Timestamp.optionally_read(context.options) == {:ok, nil}
  end

  @tag timestamp_content: "pizza"
  test "when the file content is not parsable, it returns nil", context do
    assert Timestamp.optionally_read(context.options) == {:ok, nil}
  end

  test "it writes the timestamp", context do
    %{options: options} = context
    %{start_timestamp_file: start_timestamp_file} = options
    expect(MockFile, :write!, fn ^start_timestamp_file, _ -> :ok end)

    Timestamp.optionally_write(context.movables, context.options)
  end

  test "it uses the latest movable's datetime as the timestamp", context do
    # Use the datetime of the most recent movable
    date = Date.new!(2020, 1, 1)
    time = Time.new!(13, 5, 12)
    timestamp = DateTime.new!(date, time) |> DateTime.to_unix() |> Integer.to_string()
    expect(MockFile, :write!, fn _, ^timestamp -> :ok end)

    Timestamp.optionally_write(context.movables, context.options)
  end

  @tag movable_count: 0
  test "when no movable files were found, it does not write the timestamp", context do
    expect(MockFile, :write!, 0, fn _, _ -> :ok end)

    Timestamp.optionally_write(context.movables, context.options)
  end

  @tag dry_run: true
  test "in a dry run, it does not write the timestamp", context do
    expect(MockFile, :write!, 0, fn _, _ -> :ok end)

    Timestamp.optionally_write(context.movables, context.options)
  end

  @tag timestamp_path: nil
  test "when no timestamp path is supplied, it does not write the timestamp", context do
    expect(MockFile, :write!, 0, fn _, _ -> :ok end)

    Timestamp.optionally_write(context.movables, context.options)
  end
end
