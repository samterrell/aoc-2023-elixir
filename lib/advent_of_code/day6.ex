defmodule AdventOfCode.Day6 do
  require Integer

  def example_data() do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day6.part1(AdventOfCode.Day6.example_data())
      288
  """
  # TODO: find a way to use quadratic formula and find integers in non-inclusive range
  def part1(input) do
    {times, distances} =
      for line <- input, reduce: {nil, nil} do
        {nil, nil} ->
          case String.split(line, ~r/\s+/) do
            ["Time:" | times] -> {times, nil}
            _ -> raise "Invalid times: #{inspect(line)}"
          end

        {times, nil} ->
          case String.split(line, ~r/\s+/) do
            ["Distance:" | distances] -> {times, distances}
            _ -> raise "Invalid distances: #{inspect(line)}"
          end

        _ ->
          raise "Unexpected data: #{inspect(line)}"
      end

    Stream.zip([
      Stream.map(times, &String.to_integer/1),
      Stream.map(distances, &String.to_integer/1)
    ])
    |> Stream.map(fn {t, d} ->
      for i <- 0..t, reduce: 0 do
        n -> if i * (t - i) > d, do: n + 1, else: n
      end
    end)
    |> Enum.reduce(1, &*/2)
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day6.part2(AdventOfCode.Day6.example_data())
      71503
  """

  def part2(input) do
    [time, distance] =
      Enum.take(input, 2)
      |> Enum.map(&String.replace(&1, " ", ""))
      |> Enum.map(&(String.split(&1, ":") |> Enum.at(1)))
      |> Enum.map(&String.to_integer/1)

    0..time
    |> Stream.filter(&(&1 * (time - &1) > distance))
    |> Enum.count()
  end
end
