defmodule HttpServerEx.Controllers.Logs do

  def process(conn) do
    %{ conn |
      resp_headers: %{ "Allow" => "GET, HEAD, OPTIONS" },
      status: 200
    }
  end
end
