import Config

config :automedia, file_module: MockFile
config :automedia, system_module: MockSystem
config :automedia, destination_chooser: Automedia.MockDestinationChooser
config :automedia, move: Automedia.MockMove
config :automedia, signal_backups: Automedia.Signal.MockBackups
config :automedia, signal_movable: Automedia.Signal.MockMovable
config :automedia, signal_timestamp: Automedia.Signal.MockTimestamp

config :logger, backends: []
