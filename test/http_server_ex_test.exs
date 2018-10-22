defmodule HttpServerExTest do
  use ExUnit.Case
  doctest HttpServerEx

  test "greets the world" do
    assert HttpServerEx.hello() == :world
  end
end
