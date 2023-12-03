defmodule AdventOfCode.Day3 do
  def example_data() do
    """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day3.part1(AdventOfCode.Day3.example_data())
      4361
  """
  def part1(input) do
    {symbols, numbers} =
      parse(input)
      |> Enum.split_with(fn {_, _, type, _} -> type == :symbol end)

    {_, found} =
      Enum.reduce(symbols, {numbers, []}, fn {sx, sy, _, _}, {numbers, neighbors} ->
        searchx = grow(sx)
        searchy = grow(sy)

        Enum.reduce(numbers, {[], neighbors}, fn number = {x, y, _, _}, {numbers, neighbors} ->
          if overlapping?(searchx, searchy, x, y) do
            {numbers, [number | neighbors]}
          else
            {[number | numbers], neighbors}
          end
        end)
      end)

    found
    |> Enum.map(fn {_, _, _, number} -> number end)
    |> Enum.sum()
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day3.part2(AdventOfCode.Day3.example_data())
      467835
  """
  def part2(input) do
    {symbols, numbers} =
      parse(input)
      |> Enum.split_with(fn {_, _, type, _} -> type == :symbol end)

    symbols
    |> Stream.filter(&match?({_, _, _, ?*}, &1))
    |> Stream.map(fn {x, y, _, _} -> {grow(x), grow(y)} end)
    |> Stream.map(fn {searchx, searchy} ->
      Enum.filter(numbers, fn {x, y, _, _} -> overlapping?(x, y, searchx, searchy) end)
    end)
    |> Stream.map(fn
      [{_, _, _, n1}, {_, _, _, n2}] -> n1 * n2
      _ -> 0
    end)
    |> Enum.sum()
  end

  defp grow(min..max), do: (min - 1)..(max + 1)

  defp overlapping?(x1, y1, x2, y2) do
    not Range.disjoint?(x1, x2) and not Range.disjoint?(y1, y2)
  end

  defp parse(input) do
    Stream.with_index(input)
    |> Stream.flat_map(fn {line, y} ->
      parse_line(line)
      |> Enum.map(fn {x, type, value} ->
        {x, y..y, type, value}
      end)
    end)
  end

  defp parse_line(line, offset \\ 0, acc \\ [])
  defp parse_line("", _, acc), do: acc
  defp parse_line(<<?., rest::binary>>, offset, acc), do: parse_line(rest, offset + 1, acc)

  defp parse_line(line = <<c, _::binary>>, offset, acc) when c in ?0..?9 do
    {len, val, rem} = parse_number(line)
    next = [{offset..(offset + len - 1), :integer, val} | acc]
    parse_line(rem, offset + len, next)
  end

  defp parse_line(<<symbol, rest::binary>>, offset, acc),
    do: parse_line(rest, offset + 1, [{offset..offset, :symbol, symbol} | acc])

  defp parse_number(input, len \\ 0, value \\ 0)

  defp parse_number(<<i, rest::binary>>, len, value) when i in ?0..?9,
    do: parse_number(rest, len + 1, value * 10 + i - ?0)

  defp parse_number(rem, len, value), do: {len, value, rem}
end
