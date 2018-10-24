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

  test "returns status 200" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response |> String.contains?("200 OK")
  end

  test "returns 404 when requested resource is not found" do
    conn = %Conn{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    IO.inspect conn
    assert response |> String.contains?("404 Not found")
  end
end
