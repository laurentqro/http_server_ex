defmodule HttpServerEx.Utilities.Crypto do

  def sha(content) do
    :crypto.hash(:sha, content)
    |> Base.encode16
    |> String.downcase
  end
end
