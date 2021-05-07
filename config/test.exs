import Config

config :automedia, file_module: MockFile
config :automedia, automedia_destination_chooser: Automedia.MockDestinationChooser
config :automedia, automedia_move: Automedia.MockMove
config :automedia, automedia_signal_movable: Automedia.Signal.MockMovable

config :logger, backends: []
