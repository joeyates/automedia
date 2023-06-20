defmodule Automedia.Android.Move do
  @enforce_keys ~w(destination source)a
  defstruct ~w(destination dry_run quiet source verbose)a

  @destination_chooser Application.compile_env(:automedia, :destination_chooser, Automedia.DestinationChooser)
  @move Application.compile_env(:automedia, :move, Automedia.Move)
  @android_movable Application.compile_env(:automedia, :android_movable, Automedia.Android.Movable)

  @callback run(__MODULE__) :: {:ok}
  def run(%__MODULE__{} = options) do
    with {:ok, movables} <- @android_movable.find(options.source),
         movables <- @destination_chooser.run(movables, options.destination) do
      Enum.each(movables, &(@move.move(&1, dry_run: options.dry_run)))
      {:ok}
    end
  end
end
