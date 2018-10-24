defmodule HttpServerEx.Conn do
  defstruct(
    method: "",
    path: "",
    status: nil,
    protocol: nil,
    headers: %{},
    resp_body: ""
  )
end
