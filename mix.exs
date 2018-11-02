defmodule HttpServerEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_server_ex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:cortex, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp escript do
    [main_module: HttpServerEx.Cli]
  end
end
