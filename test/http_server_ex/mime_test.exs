defmodule HttpServerEx.MIME.Test do
  use ExUnit.Case

  test "determines media type for file" do
    assert "/file.txt"  |> HttpServerEx.MIME.type == "text/plain"
    assert "/file.jpeg" |> HttpServerEx.MIME.type == "image/jpeg"
    assert "/file.png"  |> HttpServerEx.MIME.type == "image/png"
    assert "/file.gif"  |> HttpServerEx.MIME.type == "image/gif"
    assert "/foobar"    |> HttpServerEx.MIME.type == "application/octet-stream"
  end
end
