defmodule HttpServerEx.Parser do
  def parse(request) do
    [ method, path, _protocol ] = request |> String.split(" ")

    %{
      method: method,
      path: path
    }
  end
end
