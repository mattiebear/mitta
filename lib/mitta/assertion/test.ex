defmodule Mitta.Assertion.Test do
  # Equality comparisons

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end

  def assert(:==, lhs, rhs) do
    {:fail,
     """
     Assertion failed: #{lhs} == #{rhs}
     Expected:       #{lhs}
     to be equal to: #{rhs}
     """}
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end

  def assert(:>, lhs, rhs) do
    {:fail,
     """
     Assertion failed: #{lhs} > #{rhs}
     Expected:           #{lhs}
     to be greater than: #{rhs}
     """}
  end

  def assert(:<, lhs, rhs) when lhs < rhs do
    :ok
  end

  def assert(:<, lhs, rhs) do
    {:fail,
     """
     Assertion failed: #{lhs} > #{rhs}
     Expected:        #{lhs}
     to be less than: #{rhs}
     """}
  end

  def run(tests, module) do
    Enum.each(tests, fn {test_name, description} ->
      case apply(module, test_name, []) do
        :ok ->
          IO.write("*")

        {:fail, reason} ->
          IO.puts("""
            ====================================
            FAILURE: #{description}
            ====================================

            #{reason}
          """)
      end
    end)

    IO.puts("")
  end
end
