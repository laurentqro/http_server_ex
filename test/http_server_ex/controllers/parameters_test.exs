defmodule HttpServerEx.Controllers.Parameters.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "inserts decoded query parameter strings into response body" do
    conn = %Conn{
      method: "GET",
      path: "/parameters?variable_1=a%20query%20string%20parameter",
      params: %{ "variable_1" => "a query string parameter" }
    }

    conn = conn |> HttpServerEx.Controllers.Parameters.process

    assert conn.resp_body == "variable_1 = a query string parameter"
  end
end
