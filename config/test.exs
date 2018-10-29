use Mix.Config

config :http_server_ex,
  env: "test",
  public_dir: "tmp",
  logs_dir: "tmp/logs",
  basic_auth_user_id: "admin",
  basic_auth_password: "hunter2"
