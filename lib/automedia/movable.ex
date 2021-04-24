defmodule Automedia.Movable do
  @moduledoc false

  defstruct [:source, :year, :month, :day, :time, :extension, :destination]

  @type t :: %__MODULE__{
    source: Path.t(),
    year: pos_integer(),
    month: pos_integer(),
    day: pos_integer(),
    time: Time.t() | nil,
    extension: binary,
    source: Path.t() | nil
  }
end
