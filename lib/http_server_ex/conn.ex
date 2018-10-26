defmodule HttpServerEx.Conn do
  defstruct(
    method: "",
    path: "",
    status: nil,
    protocol: nil,
    headers: %{},
    req_body: "",
    resp_body: "",
    resp_headers: %{"Content-Type" => "text/html"}
  )
end
