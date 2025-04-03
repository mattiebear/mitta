defmodule Mitta.HTML do
  @external_resource tags_path = Path.join([__DIR__, "html_tags.txt"])
  @tags (for line <- File.stream!(tags_path, [], :line) do
           line |> String.trim() |> String.to_atom()
         end)

  for tag <- @tags do
    defmacro unquote(tag)(do: inner) do
      tag = unquote(tag)
      quote do: tag(unquote(tag), do: unquote(inner))
    end
  end

  defmacro markup(do: block) do
    quote do
      import Kernel, except: [div: 2]
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
