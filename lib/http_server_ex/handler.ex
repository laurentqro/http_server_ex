defmodule HttpServerEx.Handler do
  def handle(request) do
    request
    |> HttpServerEx.Parser.parse()
    |> HttpServerEx.Logger.log()
    |> HttpServerEx.Router.route()
    |> HttpServerEx.Response.respond()
  end
end
