defmodule Mitta do
  @moduledoc """
  The main library Mitta, which does meta-programmy stuff
  """

  use Mitta.Assertion

  test "things can be equal" do
    assert 1 == 1
  end

  test "things can be greater than" do
    assert 2 > 1
  end

  test "things can be less than" do
    assert 1 < 2
  end
end
