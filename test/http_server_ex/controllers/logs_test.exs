defmodule HttpServerEx.Controllers.Logs.Test do
  use ExUnit.Case

  alias HttpServerEx.Conn

  @env Application.get_env(:http_server_ex, :env)
  @logs_dir Application.get_env(:http_server_ex, :logs_dir)
  @log_file_path "/#{@env}.log"

  setup do
    File.mkdir_p(@logs_dir)
    File.write(@logs_dir <> @log_file_path, "foo")

    on_exit(fn ->
      File.rm_rf(@logs_dir)
    end)
  end

  test "OPTIONS request to /logs returns GET, HEAD, OPTIONS" do
    conn = %Conn{} |> HttpServerEx.Controllers.Logs.options()
    assert conn.resp_headers["Allow"] == "GET, HEAD, OPTIONS"
    assert conn.status == 200
  end

  test "/logs is protected with basic authentication" do
    conn = %Conn{} |> HttpServerEx.Controllers.Logs.get()
    assert conn.status == 401
  end

  test "/logs with basic authentication" do
    conn = %Conn{headers: %{"Authorization" => "Basic YWRtaW46aHVudGVyMg=="}}
    conn = conn |> HttpServerEx.Controllers.Logs.get()

    assert conn.status == 200
    assert conn.resp_body == "foo"
  end

  test "response header to request to /logs should include authentication method" do
    conn = %Conn{} |> HttpServerEx.Controllers.Logs.get()
    assert conn.resp_headers["WWW-Authenticate"] == "Basic realm=\"Access to HTTP server\""
  end

  test "#not_allowed returns status 405" do
    conn = %Conn{} |> HttpServerEx.Controllers.Logs.not_allowed()
    assert conn.status == 405
  end
end
