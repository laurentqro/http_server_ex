defmodule HttpServerEx.Parser.Test do
  use ExUnit.Case

  test "parses GET verb from the request" do
    request = "GET /hello HTTP/1.1"
    conn = request |> HttpServerEx.Parser.parse

    assert conn.method == "GET"
  end

  test "parses POST verb from the request" do
    request = "POST /hello HTTP/1.1"
    conn = request |> HttpServerEx.Parser.parse

    assert conn.method == "POST"
  end

  test "parses HEAD verb from the request" do
    request = "HEAD /hello HTTP/1.1"
    conn = request |> HttpServerEx.Parser.parse

    assert conn.method == "HEAD"
  end

  test "parses the path" do
    request = "GET /hello HTTP/1.1"
    conn = request |> HttpServerEx.Parser.parse

    assert conn.path == "/hello"
  end

  test "parses headers" do
    request = """
    GET /file1 HTTP/1.1\r
    Host: localhost:5000\r
    Connection: Keep-Alive\r
    User-Agent: Chrome\r
    Accept-Encoding: gzip,deflate\r
    \r
    """

    conn = request |> HttpServerEx.Parser.parse

    expected = %{
      "Host" => "localhost:5000",
      "Connection" => "Keep-Alive",
      "User-Agent" => "Chrome",
      "Accept-Encoding" => "gzip,deflate"
    }

    assert conn.headers == expected
  end
end
