defmodule HttpServerEx.Response do
  def respond(conn) do
    conn
    |> build_response
    |> format_response
  end

  def build_response(conn) do
    %{ conn |
      status: conn.status,
      resp_body: conn.resp_body,
      resp_headers: format_headers(conn.resp_headers)
    }
  end

  def format_response(conn) do
    """
    #{conn.protocol} #{conn.status} #{reason(conn.status)}\r
    #{conn.resp_headers}\r
    \r
    #{conn.resp_body}
    """
  end

  defp reason(status) do
    %{
      200 => "OK",
      206 => "Partial Content",
      302 => "Found",
      404 => "Not Found",
      405 => "Method Not Allowed",
      412 => "Precondition Failed",
      416 => "Range Not Satisfiable"
    }[status]
  end

  defp format_headers(headers) do
    headers
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
    |> Enum.reverse
    |> Enum.join("\r\n")
  end
end
