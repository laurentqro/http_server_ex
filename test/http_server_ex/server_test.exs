defmodule HttpServerEx.Server.Test do
  use ExUnit.Case

  setup do
    Application.stop(:http_server_ex)
    {:ok, _pid} = HttpServerEx.start("", [])
    :ok
  end

  setup do
    opts = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4000, opts)
    %{socket: socket}
  end

  setup do
    File.mkdir("tmp")
    File.write("tmp/file.txt", "hello")
  end

  test "server interaction", %{socket: socket} do
    assert send_and_receive(socket, "GET /file.txt HTTP/1.1") == "hello"
  end

  defp send_and_receive(socket, request) do
    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0, 1000)
    response
  end
end
