defmodule HttpServerEx do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: HttpServerEx.TaskSupervisor},
      {Task, fn -> HttpServerEx.Server.start(4000) end}
    ]

    opts = [strategy: :one_for_one, name: HttpServerEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
