defmodule Mitta.HTML do
  @external_resource tags_path = Path.join([__DIR__, "html_tags.txt"])
  @tags (for line <- File.stream!(tags_path, [], :line) do
           line |> String.trim() |> String.to_atom()
         end)

  defmacro markup(do: block) do
    quote do
      {:ok, var!(buffer, unquote(__MODULE__))} = start_buffer([])
      unquote(Macro.postwalk(block, &postwalk/1))
      result = render(var!(buffer, unquote(__MODULE__)))
      :ok = stop_buffer(var!(buffer, unquote(__MODULE__)))
      result
    end
  end

  def postwalk({:text, _meta, [string]}) do
    quote do: put_buffer(var!(buffer, unquote(__MODULE__)), to_string(unquote(string)))
  end

  def postwalk({tag_name, _meta, [[do: inner]]}) when tag_name in @tags do
    quote do: tag(unquote(tag_name), [], do: unquote(inner))
  end

  def postwalk({tag_name, _meta, [attrs, [do: inner]]}) when tag_name in @tags do
    quote do: tag(unquote(tag_name), unquote(attrs), do: unquote(inner))
  end

  def postwalk(ast), do: ast

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

  defmacro tag(name, attrs \\ []) do
    {inner, attrs} = Keyword.pop(attrs, :do)
    quote do: tag(unquote(name), unquote(attrs), do: unquote(inner))
  end

  defmacro tag(name, attrs, do: inner) do
    quote do
      put_buffer(var!(buffer, unquote(__MODULE__)), open_tag(unquote_splicing([name, attrs])))
      unquote(inner)
      put_buffer(var!(buffer, unquote(__MODULE__)), "</#{unquote(name)}>")
    end
  end

  def open_tag(name, []), do: "<#{name}>"

  def open_tag(name, attrs) do
    attr_html = for {key, val} <- attrs, into: "", do: " #{key}=\"#{val}\""
    "<#{name}#{attr_html}>"
  end
end
