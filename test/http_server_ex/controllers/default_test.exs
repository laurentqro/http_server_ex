defmodule HttpServerEx.Controllers.Default.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "OPTIONS method" do
    conn = %Conn{ method: "OPTIONS" }
    conn = conn |> HttpServerEx.Controllers.Default.process

    assert conn.resp_headers["Allow"] == "GET, HEAD, OPTIONS, PUT, DELETE"
    assert conn.status == 200
  end
end

