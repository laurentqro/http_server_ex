defmodule HttpServerEx.MIME do

  def type(path) do
    path
    |> String.split(".")
    |> mime
  end

  defp mime([name, ext]) do
    %{
      "jpeg" => "image/jpeg",
      "png" => "image/png",
      "gif" => "image/gif",
      "txt" => "text/plain"
    }[ext]
  end

  defp mime(_) do
    "application/octet-stream"
  end
end
