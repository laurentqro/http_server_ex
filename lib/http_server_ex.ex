defmodule HttpServerEx do
  use Application

  def start(_type, opts) do
    children = [
      {Task.Supervisor, name: HttpServerEx.TaskSupervisor},
      {Task, fn -> HttpServerEx.Server.start(opts[:port]) end}
    ]

    supervisor_opts = [strategy: :one_for_one, name: HttpServerEx.Supervisor]
    Supervisor.start_link(children, supervisor_opts)
  end
end
