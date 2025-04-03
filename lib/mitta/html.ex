defmodule Mitta.HTML do
  defmacro markup(do: block) do
    quote do
      {:ok, var!(buffer, Mitta.HTML)} = start_buffer([])
      unquote(block)
      result = render(var!(buffer, Mitta.HTML))
      :ok = stop_buffer(var!(buffer, Mitta.HTML))
      result
    end
  end

  defmacro tag(name, do: inner) do
    quote do
      put_buffer(var!(buffer, Mitta.HTML), "<#{unquote(name)}>")
      unquote(inner)
      put_buffer(var!(buffer, Mitta.HTML), "</#{unquote(name)}>")
    end
  end

  defmacro text(string) do
    quote do
      put_buffer(var!(buffer, Mitta.HTML), to_string(unquote(string)))
    end
  end

  def start_buffer(state) do
    Agent.start_link(fn -> state end)
  end

  def stop_buffer(buffer) do
    Agent.stop(buffer)
  end

  def put_buffer(buffer, content) do
    Agent.update(buffer, &[content | &1])
  end

  def render(buffer) do
    Agent.get(buffer, & &1)
    |> Enum.reverse()
    |> Enum.join()
  end
end
