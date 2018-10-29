use Mix.Config

config :http_server_ex,
  env: "development",
  public_dir: "vendor/cob_spec/public",
  logs_dir: "logs",
  basic_auth_user_id: "admin",
  basic_auth_password: "hunter2"
