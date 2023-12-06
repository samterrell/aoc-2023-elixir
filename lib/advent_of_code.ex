defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  Module.register_attribute(__MODULE__, :day_parts, accumulate: true)

  for day <- 1..25, part <- 1..2 do
    module = Module.concat(__MODULE__, :"Day#{day}")
    fun = :"part#{part}"

    exists =
      case :code.ensure_loaded(module) do
        {:module, _} -> function_exported?(module, fun, 1)
        _ -> false
      end

    if exists do
      Module.put_attribute(__MODULE__, :day_parts, {day, part})

      def run(unquote(day), unquote(part)) do
        File.stream!(unquote("data/day#{day}.txt"))
        |> Stream.map(&String.trim/1)
        |> unquote(module).unquote(fun)()
        |> IO.inspect(label: unquote("Day #{day} part #{part}"))
      end
    end
  end

  @day_parts_sorted Enum.sort(@day_parts)
  def run() do
    for {day, part} <- @day_parts_sorted do
      run(day, part)
    end
  end

  for {d, dp} <- Enum.group_by(@day_parts_sorted, fn {d, _} -> d end) do
    def run(unquote(d)) do
      for {day, part} <- unquote(dp),
          do: run(day, part)
    end
  end
end
