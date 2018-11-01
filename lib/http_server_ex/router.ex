defmodule HttpServerEx.Router do
  def route(conn) do
    case conn.path do
      "/redirect" ->
        HttpServerEx.Controllers.Redirect.process(conn)
      "/parameters" ->
        HttpServerEx.Controllers.Parameters.process(conn)
      "/logs" ->
        HttpServerEx.Controllers.Logs.process(conn)
      _ ->
        HttpServerEx.Controllers.Files.process(conn)
    end
  end
end
