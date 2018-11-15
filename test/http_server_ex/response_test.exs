defmodule HttpServerEx.Response.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  test "includes response status" do
    conn = %Conn{status: 123}
    response = conn |> HttpServerEx.Response.respond()

    assert response |> String.contains?("123")
  end

  test "includes formatted response headers" do
    conn = %Conn{resp_headers: %{Foo: "Bar"}}
    response = conn |> HttpServerEx.Response.respond()

    assert response |> String.contains?("Foo: Bar")
  end

  test "includes response body" do
    conn = %Conn{resp_body: "hello"}
    response = conn |> HttpServerEx.Response.respond()

    assert response |> String.contains?("hello")
  end

  test "response is properly formatted" do
    conn = %Conn{
      status: 200,
      resp_body: "hello",
      resp_headers: %{"Foo" => "Bar"}
    }

    response = conn |> HttpServerEx.Response.respond()

    expected = """
    HTTP/1.1 200 OK\r
    Foo: Bar\r
    \r
    hello
    """

    assert response == expected
  end

  test "response with multiple headers is properly formatted" do
    conn = %Conn{
      status: 200,
      resp_body: "hello",
      resp_headers: %{"Foo" => "Bar", "Baz" => "Boom"}
    }

    response = conn |> HttpServerEx.Response.respond()

    expected = """
    HTTP/1.1 200 OK\r
    Foo: Bar\r
    Baz: Boom\r
    \r
    hello
    """

    assert response == expected
  end
end
