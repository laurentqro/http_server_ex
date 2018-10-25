defmodule HttpServerEx.Router do
  def route(conn) do
    case conn.path do
      "/logs" ->
        HttpServerEx.Controllers.Logs.process(conn)
      _ ->
        HttpServerEx.Controllers.Files.process(conn)
    end
  end
end
