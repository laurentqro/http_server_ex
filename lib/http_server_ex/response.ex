defmodule HttpServerEx.Response do
  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def respond(conn) do
    conn
    |> build_response
    |> format_response
  end

  def build_response(conn) do
    file_path = @public_dir <> conn.path
    {:ok, file_content} = File.read(file_path)
    %{ conn | status: 200, resp_body: file_content }
  end

  def format_response(conn) do
    """
    HTTP/1.1 #{conn.status} #{reason(conn.status)}
    #{conn.resp_body}
    """
  end

  defp reason(status) do
    %{
      200 => "OK"
    }[status]
  end
end
