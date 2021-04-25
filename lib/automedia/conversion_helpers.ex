defmodule Automedia.ConversionHelpers do
  @moduledoc false

  def i(string) do
    {integer, _remainder} = Integer.parse(string)
    integer
  end

  def i_or_nil(string) do
    case Integer.parse(string) do
      :error ->
        nil
      {integer, _remainder} ->
        integer
    end
  end
end
