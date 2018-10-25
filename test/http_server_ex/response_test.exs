defmodule HttpServerEx.Response.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  @test_dir Application.get_env(:http_server_ex, :public_dir)
  @file_path "#{@test_dir}/file.txt"

  setup do
    File.mkdir_p(@test_dir)
    on_exit fn ->
      File.rm_rf @test_dir
    end
  end

  test "returns the contents of a file" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("hello")
  end

  test "returns the contents of another file" do
    File.write(@file_path, "bye")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("bye")
  end

  test "GET returns status 200" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("200 OK")
  end

  test "GET returns 404 for non-existent resource" do
    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("404 Not found")
  end

  test "HEAD returns 200" do
    conn = %Conn{ method: "HEAD", path: "/" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("200 OK")
  end

  test "HEAD returns 404 for non-existent resource" do
    conn = %Conn{ method: "HEAD", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("404 Not found")
  end

  test "HEAD response contains no body" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "HEAD", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert conn.resp_body |> String.trim == ""
  end

  test "includes formatted response headers" do
    conn = %Conn{ resp_headers: %{"Foo": "Bar"} }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("Foo: Bar")
  end
end
