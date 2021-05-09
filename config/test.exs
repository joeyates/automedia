import Config

config :automedia, file_module: MockFile
config :automedia, system_module: MockSystem
config :automedia, automedia: MockAutomedia
config :automedia, destination_chooser: Automedia.MockDestinationChooser
config :automedia, move: Automedia.MockMove
config :automedia, android_cli: Automedia.Android.MockCLI
config :automedia, android_movable: Automedia.Android.MockMovable
config :automedia, android_move: Automedia.Android.MockMove
config :automedia, signal_backups: Automedia.Signal.MockBackups
config :automedia, signal_cli: Automedia.Signal.MockCLI
config :automedia, signal_movable: Automedia.Signal.MockMovable
config :automedia, signal_move: Automedia.Signal.MockMove
config :automedia, signal_timestamp: Automedia.Signal.MockTimestamp
config :automedia, signal_unpack_backup: Automedia.Signal.MockUnpackBackup

config :logger, backends: []
