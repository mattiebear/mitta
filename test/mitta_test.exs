defmodule MittaTest do
  use ExUnit.Case
  doctest Mitta

  test "greets the world" do
    assert Mitta.hello() == :world
  end
end
