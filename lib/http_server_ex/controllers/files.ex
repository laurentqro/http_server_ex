defmodule HttpServerEx.Controllers.Files do

  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def process(conn) do
    File.read(@public_dir <> conn.path)
    |> handle_file(conn)
  end

  defp handle_file({:ok, content}, conn = %{method: "GET"}) do
    %{ conn | status: 200, resp_body: content }
  end

  defp handle_file({:ok, _content}, conn = %{method: "HEAD"}) do
    %{ conn | status: 200 }
  end

  defp handle_file({:error, :enoent}, conn) do
    %{ conn | status: 404 }
  end

  defp handle_file({:error, :eisdir}, conn) do
    %{ conn | status: 200 }
  end
end
