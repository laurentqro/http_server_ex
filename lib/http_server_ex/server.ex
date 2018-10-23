defmodule HttpServerEx.Server do

  def start(port) do
    {:ok, listening_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts "\nListening for connection requests on port #{port} ...\n"

    accept_loop(listening_socket)
  end

  def accept_loop(listening_socket) do
    IO.puts "Waiting to accept a client connection ...\n"

    {:ok, client_socket} = :gen_tcp.accept(listening_socket)

    IO.puts "Connection accepted\n"

    serve(client_socket)

    accept_loop(listening_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> HttpServerEx.Handler.handle
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0) # 0: all available bytes

    IO.puts "Received request:\n"
    IO.puts request

    request
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "Sent response:\n"
    IO.puts response

    :gen_tcp.close(client_socket)
  end
end
