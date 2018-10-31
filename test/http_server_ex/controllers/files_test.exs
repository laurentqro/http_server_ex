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

  test "PUT request creates file if it does not already exist" do
    conn = %Conn{ method: "PUT", path: "/new_file.txt", req_body: "foo" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 201

    conn = %Conn{ method: "GET", path: "/new_file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
    assert conn.resp_body == "foo"
  end

  test "PUT request updates existing file" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "PUT", path: "/file.txt", req_body: "foo" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
    assert File.read!(@file_path) == "foo"
  end

  test "DELETE deletes file" do
    File.write(@file_path, "hello")

    conn = %Conn{ method: "DELETE", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 200
    {:error, :enoent} = File.read(@file_path)
  end

  test "set media type in response header" do
    File.write(@test_dir <> "/image.jpeg", "foo")

    conn = %Conn{ method: "GET", path: "/image.jpeg" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_headers["Content-Type"] == "image/jpeg"
  end

  test "set ETag" do
    File.write(@file_path, "default content")

    conn = %Conn{ method: "GET", path: "/file.txt" }
    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.resp_headers["ETag"] == "dc50a0d27dda2eee9f65644cd7e4c9cf11de8bec"
  end

  test "PATCH makes a partial update to the file" do
    File.write(@file_path, "default content")

    conn = %Conn{
      method: "PATCH",
      path: "/file.txt",
      req_body: "patched content",
      headers: %{"If-Match" => "dc50a0d27dda2eee9f65644cd7e4c9cf11de8bec"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 204
    assert conn.resp_body == ""
    assert File.read!(@file_path) |> String.contains?("default content")
    assert File.read!(@file_path) |> String.contains?("patched content")
  end

  test "PATCH fails if request If-Match does not match ETag" do
    File.write(@file_path, "default content")

    conn = %Conn{
      method: "PATCH",
      path: "/file.txt",
      req_body: "patched content",
      headers: %{"If-Match" => "foo"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 412
    assert !(File.read!(@file_path) |> String.contains?("patched content"))
  end

  test "range request for full document" do
    text = "This is a file that contains text to read part of in order to fulfill a 206.\n"
    File.write(@file_path, text)

    conn = %Conn{
      method: "GET",
      path: "/file.txt",
      headers: %{"Range" => "bytes=0-76"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 206
    assert conn.resp_headers["Content-Range"] == "bytes 0-76/77"
    assert conn.resp_headers["Content-Length"] == 77
    assert conn.resp_body == text
  end

  test "range request for inside document" do
    text = "This is a file that contains text to read part of in order to fulfill a 206.\n"
    File.write(@file_path, text)

    conn = %Conn{
      method: "GET",
      path: "/file.txt",
      headers: %{"Range" => "bytes=10-76"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 206
    assert conn.resp_headers["Content-Range"] == "bytes 10-76/77"
    assert conn.resp_headers["Content-Length"] == 67
    assert conn.resp_body == "file that contains text to read part of in order to fulfill a 206.\n"
  end

  test "range request from beginning of file" do
    File.write(@file_path, "This is a file that contains text to read part of in order to fulfill a 206.\n")

    conn = %Conn{
      method: "GET",
      path: "/file.txt",
      headers: %{"Range" => "bytes=0-4"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 206
    assert conn.resp_headers["Content-Range"] == "bytes 0-4/77"
    assert conn.resp_headers["Content-Length"] == 5
    assert conn.resp_body == "This "
  end

  test "range request with no start value" do
    File.write(@file_path, "This is a file that contains text to read part of in order to fulfill a 206.\n")

    conn = %Conn{
      method: "GET",
      path: "/file.txt",
      headers: %{"Range" => "bytes=-6"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 206
    assert conn.resp_headers["Content-Range"] == "bytes 71-76/77"
    assert conn.resp_headers["Content-Length"] == 6
    assert conn.resp_body == " 206.\n"
  end

  test "range request with no end value" do
    File.write(@file_path, "This is a file that contains text to read part of in order to fulfill a 206.\n")

    conn = %Conn{
      method: "GET",
      path: "/file.txt",
      headers: %{"Range" => "bytes=4-"}
    }

    conn = conn |> HttpServerEx.Controllers.Files.process

    assert conn.status == 206
    assert conn.resp_headers["Content-Range"] == "bytes 4-76/77"
    assert conn.resp_headers["Content-Length"] == 72
    assert conn.resp_body == "is a file that contains text to read part of in order to fulfill a 206.\n"
  end
end
