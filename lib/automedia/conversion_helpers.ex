defmodule Automedia.ConversionHelpers do
  @moduledoc false

  def i(string) do
    {integer, _remainder} = Integer.parse(string)
    integer
  end
end
