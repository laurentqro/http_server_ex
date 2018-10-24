defmodule HttpServerEx.Response do
  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def respond(conn) do
    conn
    |> process_file
    |> build_response
    |> format_response
  end

  def build_response(conn) do
    %{ conn | status: conn.status, resp_body: conn.resp_body }
  end

  def process_file(conn) do
    case File.read(@public_dir <> conn.path) do
      { :ok, content } ->
        %{ conn | status: 200, resp_body: content }
      { :error, :enoent } ->
        %{ conn | status: 404 }
      {:error, :eisdir} ->
        %{ conn | status: 200 }
    end
  end

  def format_response(conn) do
    """
    HTTP/1.1 #{conn.status} #{reason(conn.status)}\r
    \r
    #{conn.resp_body}
    """
  end

  defp reason(status) do
    %{
      200 => "OK",
      404 => "Not found"
    }[status]
  end
end
