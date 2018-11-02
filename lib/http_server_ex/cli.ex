defmodule HttpServerEx.Cli do

  def main(args \\ []) do
    {opts, [], []} = OptionParser.parse(args, switches: [port: :integer])
    HttpServerEx.Server.start(opts[:port])
  end
end
