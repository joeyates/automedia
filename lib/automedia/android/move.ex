defmodule Automedia.Android.Move do
  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source verbose)a

  @callback run(__MODULE__) :: {:ok}
  def run(%__MODULE__{} = options) do
    with {:ok, movables} <- Automedia.Android.FilenamesWithDate.find(options.source),
         movables <- Automedia.DestinationChooser.run(movables, options.destination) do
      Enum.each(movables, &(Automedia.Move.move(&1, dry_run: options.dry_run)))
      {:ok}
    end
  end
end
