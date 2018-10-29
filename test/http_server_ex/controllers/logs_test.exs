defmodule HttpServerEx.Controllers.Logs.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "OPTIONS request to logs returns GET, HEAD, OPTIONS" do
    conn = %Conn{method: "OPTIONS", path: "/logs"}
    conn = conn |> HttpServerEx.Controllers.Logs.process

    assert conn.resp_headers["Allow"] == "GET, HEAD, OPTIONS"
    assert conn.status == 200
  end

  test "/logs is protected with basic authentication" do
    conn = %Conn{method: "GET", path: "/logs"}
    conn = conn |> HttpServerEx.Controllers.Logs.process

    assert conn.status == 401
  end

  test "/logs with basic authentication" do
    conn = %Conn{method: "GET", path: "/logs", headers: %{"Authorization" => "Basic YWRtaW46aHVudGVyMg=="}}

    conn = conn |> HttpServerEx.Controllers.Logs.process

    assert conn.status == 200
  end

  test "response to request to /logs should include authentication method" do
    conn = %Conn{method: "GET", path: "/logs"}
    conn = conn |> HttpServerEx.Controllers.Logs.process

    assert conn.resp_headers["WWW-Authenticate"] == "Basic realm=\"Access to HTTP server\""
  end
end
