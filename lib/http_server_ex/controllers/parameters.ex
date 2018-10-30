defmodule HttpServerEx.Controllers.Parameters do

  def process(conn) do
    %{ conn |
      status: 200,
      resp_body: render_params(conn.params)
    }
  end

  defp render_params(params) do
    params
    |> Enum.map(fn {k, v} -> "#{k} = #{v}" end)
    |> Enum.join("\r\n")
  end
end
