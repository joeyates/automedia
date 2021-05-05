defmodule Automedia.Android.Move do
  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source verbose)a

  def run(%__MODULE__{} = options) do
    options.source
    |> Automedia.Android.FilenamesWithDate.find()
    |> Automedia.DestinationChooser.run(options.destination)
    |> Enum.map(&(Automedia.Move.move(&1, dry_run: options.dry_run)))
  end
end
