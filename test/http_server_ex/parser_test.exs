defmodule HttpServerEx.Parser.Test do
  use ExUnit.Case

  test "parses GET verb from the request" do
    request = """
      GET /hello HTTP/1.1
    """
    conn = request |> HttpServerEx.Parser.parse

    assert conn.method == "GET"
  end
end
