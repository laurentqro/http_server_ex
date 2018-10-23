defmodule HttpServerEx.Response do
  @public_dir Application.get_env(:http_server_ex, :public_dir)

  def respond(conn) do
    file_path = @public_dir <> conn.path
    {:ok, file_content} = File.read(file_path)
    file_content
  end
end
