defmodule Automedia.Move do
  @moduledoc false

  require Logger

  require Automedia.Movable

  @file_module Application.compile_env(:automedia, :file_module, File)

  @callback move(Automedia.Movable.t(), keyword()) :: {:ok}

  def move(%Automedia.Movable{destination: destination} = movable, options) do
    exists = @file_module.regular?(destination)
    if exists do
      handle_existing(movable, options)
    else
      destination = movable.destination
      source = movable.source
      do_move(source, destination, options)
    end

    {:ok}
  end

  defp handle_existing(movable, options) do
    destination = movable.destination
    source = movable.source
    move_duplicates = Keyword.get(options, :move_duplicates)
    if move_duplicates do
      filename = Path.basename(destination)
      away = Path.join(move_duplicates, filename)
      Logger.info "Moving duplicate '#{source}' to '#{away}' as '#{destination}' already exists"
      do_move(source, away, options)
    else
      Logger.info "Skipping move of '#{source}' to '#{destination}' - destination file already exists"
    end
  end

  defp do_move(source, destination, options) do
    dry_run = Keyword.get(options, :dry_run, false)
    path = Path.dirname(destination)
    if !@file_module.dir?(path) do
      Logger.info "Creating directory '#{path}'"
      if !dry_run, do: @file_module.mkdir_p!(path)
    end
    Logger.info "Moving '#{source}' to '#{destination}'"
    if !dry_run, do: @file_module.rename!(source, destination)
  end
end
