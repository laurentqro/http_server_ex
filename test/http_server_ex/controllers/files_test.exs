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
end
