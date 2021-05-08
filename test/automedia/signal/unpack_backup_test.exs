defmodule Automedia.Signal.UnpackBackupTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  setup context do
    call_result = Map.get(context, :call_result, {"", 0})
    destination_dir_exists = Map.get(context, :destination_dir_exists, false)
    dry_run = Map.get(context, :dry_run, false)
    password_file_exists = Map.get(context, :password_file_exists, true)

    stub(MockFile, :dir?, fn "/destination" -> destination_dir_exists end)
    stub(MockFile, :mkdir_p!, fn "/destination" -> :ok end)
    stub(MockFile, :regular?, fn "/password/file" -> password_file_exists end)
    stub(MockFile, :rm_rf!, fn "/destination" -> :ok end)
    stub(MockSystem, :cmd, fn _, _, _ -> call_result end)
    stub(Automedia.Signal.MockBackups, :from, fn _ -> {:ok, ["earlier", "later"]} end)

    options = %Automedia.Signal.UnpackBackup{
      destination: "/destination",
      dry_run: dry_run,
      password_file: "/password/file",
      source: "/source"
    }

    Map.merge(context, %{options: options})
  end

  test "it creates the destination directory", context do
    expect(MockFile, :mkdir_p!, fn "/destination" -> :ok end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  @tag destination_dir_exists: true
  test "when the destination exists, it first deletes it", context do
    expect(MockFile, :rm_rf!, fn "/destination" -> :ok end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  @tag destination_dir_exists: true
  @tag dry_run: true
  test "on a dry run, when the destination exists, it doesn't delete it", context do
    expect(MockFile, :rm_rf!, 0, fn _ -> :ok end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  @tag dry_run: true
  test "on a dry run, it doesn't create the destination directory", context do
    expect(MockFile, :mkdir_p!, 0, fn _ -> :ok end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  test "it uses signal-backup-decode to unpack the backup", context do
    expect(MockSystem, :cmd, fn "signal-backup-decode", _, _ -> {"", 0} end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  test "it unpacks the latest backup", context do
    expect(MockSystem, :cmd, fn _, [_, _, _, _, _, _, "later"], _ -> {"", 0} end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  test "it unpacks to the destination directory", context do
    expect(MockSystem, :cmd, fn _, [_, _, "--output-path", "/destination", _, _, _], _ -> {"", 0} end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  test "it supplies the password file", context do
    expect(MockSystem, :cmd, fn _, [_, _, _, _, "--password-file", "/password/file", _], _ -> {"", 0} end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  test "it returns ok", context do
    assert Automedia.Signal.UnpackBackup.run(context.options) == {:ok}
  end

  @tag dry_run: true
  test "on a dry run, it doesn't unpack the backup", context do
    expect(MockSystem, :cmd, 0, fn _, _, _ -> {"", 0} end)

    Automedia.Signal.UnpackBackup.run(context.options)
  end

  @tag password_file_exists: false
  test "when the password file is missing, it exist with an error", context do
    assert catch_exit(Automedia.Signal.UnpackBackup.run(context.options)) == 1
  end

  @tag call_result: {"Uh-oh!", 1}
  test "when the system call fails, it exist with an error", context do
    assert catch_exit(Automedia.Signal.UnpackBackup.run(context.options)) == 1
  end
end
