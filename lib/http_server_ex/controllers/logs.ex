defmodule HttpServerEx.Controllers.Logs do
  @user_id   Application.get_env(:http_server_ex, :basic_auth_user_id)
  @password  Application.get_env(:http_server_ex, :basic_auth_password)

  alias HttpServerEx.Logger

  def process(conn = %{ method: "OPTIONS" }) do
    %{ conn |
      resp_headers: %{ "Allow" => "GET, HEAD, OPTIONS" },
      status: 200
    }
  end

  def process(conn = %{ method: "GET" }) do
    conn
    |> authenticate
    |> handle_authentication(conn)
  end

  def process(conn) do
    %{ conn | status: 200 }
  end

  defp authenticate(conn) do
    conn.headers["Authorization"] == "Basic #{base64_encoded_credentials()}"
  end

  defp handle_authentication(_authorized = true, conn) do
    %{ conn |
      status: 200,
      resp_body: Logger.read_logs()
    }
  end

  defp handle_authentication(_authorized = false, conn) do
    %{ conn |
      status: 401,
      resp_headers: conn.resp_headers |> Map.merge(www_authenticate_header())
    }
  end

  defp base64_encoded_credentials do
    Base.encode64("#{@user_id}:#{@password}")
  end

  defp www_authenticate_header do
    %{ "WWW-Authenticate" => "Basic realm=\"Access to HTTP server\"" }
  end
end
