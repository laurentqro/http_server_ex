defmodule HttpServerEx.Controllers.Files do

  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def process(conn) do
    File.read(@public_dir <> conn.path)
    |> handle_file(conn)
  end

  defp handle_file({:ok, content}, conn = %{method: "GET"}) do
    %{ conn |
      status: 200,
      resp_body: content
    }
  end

  defp handle_file({:ok, _content}, conn = %{method: "HEAD"}) do
    %{ conn | status: 200 }
  end

  defp handle_file(_, conn = %{method: "OPTIONS"}) do
    %{ conn |
      status: 200,
      resp_headers: %{"Allow" => "GET, HEAD, OPTIONS, PUT, DELETE"}
    }
  end

  defp handle_file({:error, :enoent}, conn = %{method: method}) when method in ["GET", "HEAD"] do
    %{ conn | status: 404 }
  end

  defp handle_file({:ok, _content}, conn = %{method: "PUT"}) do
    write_file(conn.path, conn.req_body)
    %{ conn | status: 200 }
  end

  defp handle_file({:error, :enoent}, conn = %{method: "PUT"}) do
    write_file(conn.path, conn.req_body)
    %{ conn | status: 201 }
  end

  defp handle_file({:error, :eisdir}, conn) do
    %{ conn |
      status: 200,
      resp_body: render_dir_listing(conn)
    }
  end

  defp handle_file(_, conn = %{method: _}) do
    %{ conn | status: 405 }
  end

  defp render_dir_listing(conn) do
    conn
    |> dir_listing
    |> Enum.map(&to_link/1)
    |> Enum.map(&to_li/1)
    |> Enum.join
  end

  defp dir_listing(conn) do
    @public_dir <> conn.path
    |> File.ls!
  end

  defp to_link(file) do
    ~s(<a href="/#{file}">#{file}</a>)
  end

  defp to_li(item) do
    "<li>#{item}</li>"
  end

  defp write_file(path, content) do
    @public_dir <> path
    |> File.write(content)
  end
end
