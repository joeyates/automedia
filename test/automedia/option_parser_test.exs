defmodule Automedia.OptionParserTest do
  use ExUnit.Case, async: true
  doctest Automedia.OptionParser

  defmodule Foo do
    defstruct [:bar]
  end

  describe "run" do
    test "it returns options in the supplied struct" do
      assert Automedia.OptionParser.run(["--bar", "baz"], switches: [bar: :string], struct: Foo) == {:ok, %Foo{bar: "baz"}, []}
    end
  end
end
