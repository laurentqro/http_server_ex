defmodule HttpServerEx.Controllers.Logs.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "OPTIONS request to logs returns GET, HEAD, OPTIONS" do
    conn = %Conn{ method: "OPTIONS", path: "/logs" }
    conn = conn |> HttpServerEx.Controllers.Logs.process

    assert conn.resp_headers["Allow"] == "GET, HEAD, OPTIONS"
    assert conn.status == 200
  end
end
