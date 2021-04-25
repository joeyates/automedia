defmodule Automedia.Movable do
  @moduledoc false

  defstruct [:source, :date, :time, :extension, :destination]

  @type t :: %__MODULE__{
    source: Path.t(),
    date: Date.t(),
    time: Time.t() | nil,
    extension: binary,
    destination: Path.t() | nil
  }
end
