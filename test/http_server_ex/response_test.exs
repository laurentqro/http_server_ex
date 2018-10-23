defmodule HttpServerEx.Response.Test do
  use ExUnit.Case

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

    conn = %{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response == "hello"
  end

  test "returns the contents of another file" do
    File.write(@file_path, "bye")

    conn = %{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response == "bye"
  end
end
