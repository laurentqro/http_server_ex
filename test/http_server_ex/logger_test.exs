defmodule HttpServerEx.Logger.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  @env Application.get_env(:http_server_ex, :env)
  @logs_dir Application.get_env(:http_server_ex, :logs_dir)
  @log_file_path "/#{@env}.log"

  setup do
    File.mkdir_p(@logs_dir)

    on_exit(fn ->
      File.rm_rf(@logs_dir)
    end)
  end

  test "requests are logged" do
    %Conn{method: "GET", path: "/foo"}
    |> HttpServerEx.Logger.log()

    %Conn{method: "PUT", path: "/bar"}
    |> HttpServerEx.Logger.log()

    assert File.read!(@logs_dir <> @log_file_path) |> String.contains?("GET /foo HTTP/1.1")
    assert File.read!(@logs_dir <> @log_file_path) |> String.contains?("PUT /bar HTTP/1.1")
  end
end
