defmodule AdventOfCode.Day1 do
  def example_data(:part1) do
    """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
    |> String.split("\n")
  end

  def example_data(:part2) do
    """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """
    |> String.split("\n")
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day1.part1(AdventOfCode.Day1.example_data(:part1))
      142
  """
  def part1(input) do
    Stream.map(input, fn line ->
      for <<char>> <- String.graphemes(line),
          char in ?0..?9,
          int = char - ?0,
          reduce: {nil, nil} do
        {nil, nil} -> {int, int}
        {first, _} -> {first, int}
      end
    end)
    |> Stream.filter(fn x -> x != {nil, nil} end)
    |> Stream.map(fn {l, r} -> l * 10 + r end)
    |> Enum.sum()
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day1.part2(AdventOfCode.Day1.example_data(:part2))
      281
  """
  def part2(input) do
    Stream.map(input, &parse_line/1)
    |> Stream.reject(&is_nil/1)
    |> Stream.map(fn {l, r} -> l * 10 + r end)
    |> Enum.sum()
  end

  @good_strings [
    {0, "zero"},
    {1, "one"},
    {2, "two"},
    {3, "three"},
    {4, "four"},
    {5, "five"},
    {6, "six"},
    {7, "seven"},
    {8, "eight"},
    {9, "nine"}
  ]

  defp parse_line(str, state \\ nil)
  defp parse_line("", state), do: state

  for {v, s} <- @good_strings do
    defp parse_line(unquote(s) <> _ = input, state),
      do: parse_line(String.slice(input, 1..-1), handle_hit(state, unquote(v)))

    defp parse_line(unquote("#{v}") <> _ = input, state),
      do: parse_line(String.slice(input, 1..-1), handle_hit(state, unquote(v)))
  end

  defp parse_line(<<_, rest::binary>>, state), do: parse_line(rest, state)

  defp handle_hit(nil, int), do: {int, int}
  defp handle_hit({first, _}, int), do: {first, int}
end
