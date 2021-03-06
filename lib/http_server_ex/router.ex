defmodule HttpServerEx.Router do
  def route(conn) do
    case conn do
      %{method: "GET", path: "/redirect"} ->
        HttpServerEx.Controllers.Redirect.get(conn)

      %{method: "GET", path: "/parameters"} ->
        HttpServerEx.Controllers.Parameters.get(conn)

      %{method: "GET", path: "/logs"} ->
        HttpServerEx.Controllers.Logs.get(conn)

      %{method: "OPTIONS", path: "/logs"} ->
        HttpServerEx.Controllers.Logs.options(conn)

      %{method: _, path: "/logs"} ->
        HttpServerEx.Controllers.Logs.not_allowed(conn)

      _ ->
        HttpServerEx.Controllers.Files.process(conn)
    end
  end
end
