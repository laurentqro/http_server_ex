defmodule HttpServerEx.Conn do
  defstruct(
    method: "",
    path: "",
    status: nil,
    protocol: nil,
    headers: %{},
    resp_body: "",
    resp_headers: %{"Content-Type" => "text/html"}
  )
end
