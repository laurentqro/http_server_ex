defmodule HttpServerEx.Handler.Test do
  use ExUnit.Case

  @test_dir Application.get_env(:http_server_ex, :public_dir)
  @file_path "#{@test_dir}/file.txt"

  setup do
    File.mkdir_p(@test_dir)

    on_exit(fn ->
      File.rm_rf(@test_dir)
    end)
  end

  test "returns content of file when requested" do
    File.write(@file_path, "hello")
    response = "GET /file.txt HTTP/1.1" |> HttpServerEx.Handler.handle()

    assert response |> String.contains?("hello")
  end
end
