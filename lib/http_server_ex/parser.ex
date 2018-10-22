defmodule HttpServerEx.Parser do
  def parse(request) do
    [ method, _path, _protocol ] = request |> String.split(" ")
    %{ method: method }
  end
end
