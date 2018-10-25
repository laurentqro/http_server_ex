defmodule HttpServerEx.Controllers.Files.Test do
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
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_body == "hello"
    assert conn.status == 200
  end

  test "returns the contents of another file" do
    File.write(@file_path, "bye")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_body == "bye"
    assert conn.status == 200
  end

  test "GET returns 404 for non-existent file" do
    conn = %Conn{ method: "GET", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 404
  end

  test "HEAD returns 200 for existing file" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "HEAD" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
  end

  test "HEAD returns 404 for non-existent resource" do
    conn = %Conn{ method: "HEAD", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 404
  end

  test "HEAD response contains no body" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "HEAD", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_body == ""
  end

  test "OPTIONS Allow header has GET, HEAD, OPTIONS, PUT, DELETE" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "OPTIONS", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_headers["Allow"] == "GET, HEAD, OPTIONS, PUT, DELETE"
    assert conn.status == 200
  end

  test "OPTIONS request to non existing file still returns status 200" do
    conn = %Conn{ method: "OPTIONS", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
  end

  test "response body has directory links when request path is directory" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "GET", path: "/" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
    assert conn.resp_body |> String.contains?(~s(<a href="/file.txt">file.txt</a>))
  end

  test "gibberish request method returns status 405 method not allowed" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "PFTCURPN", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 405
  end
end
