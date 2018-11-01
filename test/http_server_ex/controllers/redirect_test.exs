defmodule HttpServerEx.Controllers.Redirect.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "HTTP request redirection" do
    conn = %Conn{
      path: "/redirect"
    }

    conn = conn |> HttpServerEx.Controllers.Redirect.get

    assert conn.status == 302
    assert conn.resp_headers["Location"] == "/"
  end
end
