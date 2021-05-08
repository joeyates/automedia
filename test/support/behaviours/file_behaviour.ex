defmodule FileBehaviour do
  @callback dir?(Path.t()) :: boolean()
  @callback mkdir_p!(Path.t()) :: :ok
  @callback read!(Path.t()) :: String.t()
  @callback regular?(Path.t()) :: boolean()
  @callback rename!(Path.t(), Path.t()) :: :ok
  @callback write!(Path.t(), String.t()) :: :ok
end
