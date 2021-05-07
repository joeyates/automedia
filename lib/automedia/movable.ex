defmodule Automedia.Movable do
  @moduledoc false

  @enforce_keys ~w(date extension source)a
  defstruct ~w(date destination extension source time)a

  @type t :: %__MODULE__{
    source: Path.t(),
    date: Date.t(),
    time: Time.t() | nil,
    extension: binary,
    destination: Path.t() | nil
  }
end
