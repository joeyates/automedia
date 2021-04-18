defmodule Automedia.Movable do
  defstruct [:pathname, :year, :month, :day, :time, :extension]

  @type t :: %__MODULE__{
          pathname: Path.t(),
          year: pos_integer(),
          month: pos_integer(),
          day: pos_integer(),
          time: binary | nil,
          extension: binary
        }

  def find(path) do
    Automedia.Movable.FilenamesWithDate.find(path)
  end
end
