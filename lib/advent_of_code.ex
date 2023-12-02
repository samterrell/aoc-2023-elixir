defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """
  @day 1

  for day <- 1..@day, part <- 1..2 do
    def unquote(:"day#{day}_part#{part}")() do
      File.stream!(unquote("data/day#{day}.txt"))
      |> unquote(Module.concat(__MODULE__, :"Day#{day}")).unquote(:"part#{part}")()
      |> IO.inspect(label: "Answer")
    end
  end
end
