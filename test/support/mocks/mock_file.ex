defmodule FileBehaviour do
  @callback dir?(Path.t()) :: boolean()
  @callback mkdir_p!(Path.t()) :: :ok
  @callback regular?(Path.t()) :: boolean()
  @callback rename!(Path.t(), Path.t()) :: :ok
end

Mox.defmock(MockFile, for: FileBehaviour)
