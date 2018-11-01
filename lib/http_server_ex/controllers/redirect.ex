defmodule HttpServerEx.Controllers.Redirect do

  def get(conn) do
    %{ conn |
      status: 302,
      resp_headers: %{ "Location" => "/"}
    }
  end
end
