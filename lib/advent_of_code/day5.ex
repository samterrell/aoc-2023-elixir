defmodule AdventOfCode.Day5 do
  def example_data() do
    """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day5.part1(AdventOfCode.Day5.example_data())
      35
  """
  def part1(input) do
    {{next, numbers}, data} =
      parse(input)
      |> Map.pop(nil)

    part1(data, next, numbers)
  end

  def part1(_map, "location", numbers) do
    Enum.min(numbers)
  end

  def part1(map, next, numbers) do
    {next, set} = map[next]

    numbers =
      for number <- numbers do
        Enum.find_value(set, number, fn [o, i, l] ->
          fixed = number - i
          if number >= i and fixed < l, do: fixed + o
        end)
      end

    part1(map, next, numbers)
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day5.part2(AdventOfCode.Day5.example_data())
      46
  """

  # TODO:
  # Saturate the sets into a structure like:
  # [{start, shift}, {start, shift}, ...]
  # Merge the mapings all the way down into one long list that maps from seed all the way to location
  # Use a tree structure or similar to do as-of-join/price-is-right style search

  # Already attempted:
  # usign range structures, and cracking them as they pass through the layers.
  # Problem is you still need to saturate the mappings, though you can probably get away without merging them?

  def part2(input) do
    {{next, numbers}, data} =
      parse(input)
      |> Map.pop(nil)

    Enum.chunk_every(numbers, 2)
    |> Enum.map(fn [s, l] -> s..(s + l - 1) end)
    |> Stream.concat()
    |> Stream.map(&part1(data, next, [&1]))
    |> Enum.min()
  end

  defp parse(stream) do
    {_state, acc} = Enum.reduce(stream, {nil, %{}}, &handle/2)
    acc
  end

  defp handle("seeds: " <> numbers, {_, acc}) do
    seeds =
      String.split(numbers, ~r/\s+/)
      |> Enum.map(&String.to_integer/1)

    {nil, Map.put(acc, nil, {"seed", seeds})}
  end

  defp handle("", {_, acc}), do: {nil, acc}
  defp handle(<<c, _::binary>>, {_, acc}) when c in ~c" \n", do: {nil, acc}

  defp handle(line, {nil, acc}) do
    case Regex.run(~r/^(\w+)-to-(\w+)\s+map:\s*$/, line) do
      nil -> raise "Bad map descriptor: #{inspect(line)}"
      [_, from, to] -> {from, Map.put(acc, from, {to, []})}
    end
  end

  defp handle(line, {from, acc}) do
    numbers =
      String.split(line, ~r/\s+/)
      |> Enum.map(&String.to_integer/1)

    {to, current} = Map.get(acc, from)
    acc = Map.put(acc, from, {to, [numbers | current]})
    {from, acc}
  end
end
