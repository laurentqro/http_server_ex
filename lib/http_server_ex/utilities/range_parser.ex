defmodule HttpServerEx.Utilities.RangeParser do

  def parse_range_bounds(content_size, ["", chunk_size]) do
    range_start = content_size - String.to_integer(chunk_size)
    range_end   = content_size - 1

    { range_start, range_end }
  end

  def parse_range_bounds(content_size, [range_start, ""]) do
    range_start = range_start |> String.to_integer
    range_end   = content_size - 1

    { range_start, range_end }
  end

  def parse_range_bounds(_content_size, [range_start, range_end]) do
    { String.to_integer(range_start), String.to_integer(range_end) }
  end
end
