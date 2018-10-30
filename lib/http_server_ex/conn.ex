defmodule HttpServerEx.Conn do
  defstruct(
    method: "",
    path: "",
    status: nil,
    protocol: "HTTP/1.1",
    headers: %{},
    params: %{},
    req_body: "",
    resp_body: "",
    resp_headers: %{}
  )
end
