defmodule HttpServerEx.Router do
  def route(conn) do
    case conn do
      %{method: "GET", path: "/redirect"} ->
        HttpServerEx.Controllers.Redirect.get(conn)
      %{path: "/parameters"} ->
        HttpServerEx.Controllers.Parameters.process(conn)
      %{path: "/logs"} ->
        HttpServerEx.Controllers.Logs.process(conn)
      _ ->
        HttpServerEx.Controllers.Files.process(conn)
    end
  end
end
