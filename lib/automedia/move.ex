defmodule Automedia.Move do
  @moduledoc false

  require Logger

  require Automedia.Movable

  @file_module Application.get_env(:automedia, :file_module, File)

  @callback move(Automedia.Movable.t(), keyword()) :: {:ok}
  def move(%Automedia.Movable{source: source, destination: destination}, options) do
    dry_run = Keyword.get(options, :dry_run, false)
    path = Path.dirname(destination)
    if !@file_module.dir?(path) do
      Logger.info "Creating directory '#{path}'"
      if !dry_run, do: @file_module.mkdir_p!(path)
    end
    if @file_module.regular?(destination) do
      Logger.info "Skipping move of '#{source}' to '#{destination}' - destination file already exists"
    else
      Logger.info "Moving '#{source}' to '#{destination}'"
      if !dry_run, do: @file_module.rename!(source, destination)
    end

    {:ok}
  end
end
