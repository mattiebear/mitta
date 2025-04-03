defmodule Mitta.Template do
  import Mitta.HTML

  def render do
    markup do
      table do
        tr do
          for i <- 0..5 do
            td do
              text("Cell #{i}")
            end
          end
        end
      end

      div id: "some_id" do
        text("Some nested content")
      end
    end
  end
end
