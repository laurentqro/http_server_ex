defmodule HttpServerEx.Handler do
  def handle(request) do
    request
    |> HttpServerEx.Parser.parse
    |> HttpServerEx.Router.route
    |> HttpServerEx.Response.respond
  end
end
