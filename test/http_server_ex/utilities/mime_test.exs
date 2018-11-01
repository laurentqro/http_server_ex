defmodule HttpServerEx.Utilities.MIME.Test do
  use ExUnit.Case

  alias HttpServerEx.Utilities.MIME

  test "determines media type for file" do
    assert "/file.txt"  |> MIME.type == "text/plain"
    assert "/file.jpeg" |> MIME.type == "image/jpeg"
    assert "/file.png"  |> MIME.type == "image/png"
    assert "/file.gif"  |> MIME.type == "image/gif"
    assert "/foobar"    |> MIME.type == "application/octet-stream"
  end
end
