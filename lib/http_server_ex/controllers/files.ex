defmodule HttpServerEx.Controllers.Files do

  alias HttpServerEx.Utilities.Crypto
  alias HttpServerEx.Utilities.MIME
  alias HttpServerEx.Utilities.RangeParser

  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def get(conn) do
    case read_file(conn) do
      {:ok, content} ->
        conn = %{ conn | resp_headers: %{"ETag" => Crypto.sha(content)} }
        ok(conn, content)
      {:error, :eisdir} ->
        ok(conn, render_dir_listing(conn))
      {:error, :enoent} ->
        not_found(conn)
    end
  end

  defp partial(range) do
    content_size = byte_size(content)
    range = range |> String.split("-")
    { range_start, range_end } = RangeParser.parse_range_bounds(content_size, range)

    case valid_range?(content_size, range_start, range_end) do
      true ->
        partial_content = content |> slice_content(range_start, range_end)
        %{ conn |
          status: 206,
          resp_body: partial_content,
          resp_headers: %{
            "Content-Range" => "bytes #{range_start}-#{range_end}/#{content_size}",
            "Content-Length" => byte_size(partial_content)
          }
        }
      _ ->
        %{ conn |
          status: 416,
          resp_body: content,
          resp_headers: %{
            "Content-Range" => "bytes */#{content_size}",
            "Content-Length" => content_size
          }
        }
    end
  end

  def head(conn) do
    conn
    |> read_file
    |> handle_file(conn)
  end

  def put(conn) do
    conn
    |> read_file
    |> handle_file(conn)
  end

  def patch(conn) do
    conn
    |> read_file
    |> handle_file(conn)
  end

  def options(conn) do
    %{ conn |
      status: 200,
      resp_headers: %{"Allow" => "GET, HEAD, OPTIONS, PUT, DELETE"}
    }
  end

  def delete(conn) do
    File.rm(@public_dir <> conn.path)
    %{ conn | status: 200 }
  end

  defp read_file(conn) do
    File.read(@public_dir <> conn.path)
  end

  defp ok(conn, body) do
    %{ conn |
      status: 200,
      resp_body: body,
      resp_headers: Map.merge(base_headers(conn), conn.resp_headers)
    }
  end

  defp not_found(conn) do
    %{ conn | status: 404 }
  end

  defp handle_file({:ok, _content}, conn = %{method: "HEAD"}) do
    %{ conn | status: 200 }
  end

  defp handle_file({:error, :enoent}, conn = %{method: "HEAD"}) do
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

  defp handle_file({:ok, content}, conn = %{method: "PATCH"}) do
    conn
    |> patch_authorized?(content)
    |> update_file(conn)
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

  defp update_file(_authorized = true, conn) do
    @public_dir <> conn.path
    |> File.write(conn.req_body, [:append])
    %{ conn | status: 204 }
  end

  defp update_file(_authorized = false, conn) do
    %{ conn | status: 412 }
  end

  defp patch_authorized?(conn, content) do
    conn.headers["If-Match"] == Crypto.sha(content)
  end

  defp slice_content(content, range_start, range_end) do
    chunk_size = range_end - range_start + 1
    content |> binary_part(range_start, chunk_size)
  end

  defp valid_range?(content_size, range_start, range_end) do
    range_start >= 0 && range_end < content_size
  end

  defp base_headers(conn) do
    %{ "Content-Type" => MIME.type(conn.path) }
  end
end
