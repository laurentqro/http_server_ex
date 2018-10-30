defmodule HttpServerEx.Parser do
  alias HttpServerEx.Conn

  def parse(request) do
    [ head    | body ]         = request |> String.split("\r\n\r\n")
    [ request | headers ]      = head    |> String.split("\r\n")

    [ method, path, protocol ] = request |> String.split(" ")

    %Conn{
      method: method,
      path: URI.parse(path).path,
      protocol: protocol,
      headers: parse_headers(headers, %{}),
      params: parse_params(path),
      req_body: List.first(body)
    }
  end

  defp parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  defp parse_headers([], headers), do: headers

  defp parse_params(path) do
    path
    |> String.split("?")
    |> List.last
    |> URI.decode_query
  end
end
