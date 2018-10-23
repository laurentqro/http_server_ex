defmodule HttpServerEx.Response.Test do
  use ExUnit.Case

  test "returns the contents of a file" do
    File.mkdir("tmp")
    File.write("tmp/file.txt", "hello")
    file_path = "tmp/file.txt"

    { :ok, file_content } = File.read(file_path)

    conn = %{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response == file_content
  end

  test "returns the contents of another file" do
    File.mkdir("tmp")
    File.write("tmp/file.txt", "goodbye")
    file_path = "tmp/file.txt"

    { :ok, file_content } = File.read(file_path)

    conn = %{ method: "GET", path: "/file.txt" }
    response = conn |> HttpServerEx.Response.respond

    assert response == file_content
  end
end
