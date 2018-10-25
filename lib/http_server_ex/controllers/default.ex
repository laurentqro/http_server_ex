defmodule HttpServerEx.Controllers.Default do

  def process(conn) do
    %{ conn |
      resp_headers: %{ "Allow" => "GET, HEAD, OPTIONS, PUT, DELETE" },
      status: 200
    }
  end
end
