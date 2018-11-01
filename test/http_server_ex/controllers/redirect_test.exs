defmodule HttpServerEx.Controllers.Redirect.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "HTTP request redirection" do
    conn = %Conn{
      method: "GET",
      path: "/redirect"
    }

    conn = conn |> HttpServerEx.Controllers.Redirect.process

    assert conn.status == 302
    assert conn.resp_headers["Location"] == "/"
  end
end
