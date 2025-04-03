defmodule Mitta.Assertion do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :tests, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def run, do: Mitta.Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_name = String.to_atom(description)

    quote do
      @tests {unquote(test_name), unquote(description)}
      def unquote(test_name)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Mitta.Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end
