defmodule HttpServerEx.Logger do

  @env Application.get_env(:http_server_ex, :env)
  @logs_dir Application.get_env(:http_server_ex, :logs_dir)
  @log_file_path ("/#{@env}.log")

  def log(request) do
    File.write(
      @logs_dir <> @log_file_path,
      "#{request.method} #{request.path} #{request.protocol}\n",
      [:append]
    )
    request
  end

  def read_logs do
    File.read!(@logs_dir <> @log_file_path)
  end
end
