defmodule HttpServerEx.Response.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "includes response status" do
    conn = %Conn{ status: 123 }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("123")
  end

  test "includes formatted response headers" do
    conn = %Conn{ resp_headers: %{"Foo": "Bar"} }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("Foo: Bar")
  end

  test "includes response body" do
    conn = %Conn{ resp_body: "hello" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("hello")
  end
end
