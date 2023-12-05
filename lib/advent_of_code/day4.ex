defmodule AdventOfCode.Day4 do
  defmodule Card do
    import NimbleParsec
    defstruct id: nil, winners: MapSet.new(), mine: MapSet.new()

    defparsecp(
      :parser,
      ignore(string("Card"))
      |> ignore(repeat(ascii_char([?\s])))
      |> integer(min: 1)
      |> ignore(ascii_char([?:]))
      |> wrap(
        repeat(
          ignore(repeat(ascii_char([?\s])))
          |> integer(min: 1)
        )
      )
      |> ignore(repeat(ascii_char([?\s])))
      |> ignore(ascii_char([?|]))
      |> wrap(
        repeat(
          ignore(repeat(ascii_char([?\s])))
          |> integer(min: 1)
        )
      )
    )

    def parse!(input) do
      case parse(input) do
        {:ok, card} -> card
        problem -> raise problem
      end
    end

    def parse(input) do
      with {:ok, [id, winners, mine], _, _, _, _} <- parser(input) do
        {:ok, %__MODULE__{id: id, winners: MapSet.new(winners), mine: MapSet.new(mine)}}
      end
    end
  end

  def example_data() do
    """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day4.part1(AdventOfCode.Day4.example_data())
      13
  """
  def part1(input) do
    input
    |> Stream.map(&Card.parse!/1)
    |> Stream.map(&MapSet.intersection(&1.winners, &1.mine))
    |> Stream.map(&Enum.count/1)
    |> Stream.filter(&(&1 > 0))
    |> Stream.map(&Bitwise.bsl(1, &1 - 1))
    |> Enum.sum()
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day4.part2(AdventOfCode.Day4.example_data())
      30
  """
  def part2(input) do
    input
    |> Stream.map(&Card.parse!/1)
    |> Enum.reduce({%{}, %{}}, fn card, {current, copies} ->
      wins =
        MapSet.intersection(card.winners, card.mine)
        |> Enum.count()

      {existing, copies} = Map.pop(copies, card.id, 0)
      total = existing + 1
      current = Map.put(current, card.id, total)

      copies =
        if wins > 0 do
          Enum.reduce((card.id + 1)..(card.id + wins), copies, &increment(&2, &1, total))
        else
          copies
        end

      {current, copies}
    end)
    |> elem(0)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp increment(acc, id, by) do
    if acc[id], do: put_in(acc[id], acc[id] + by), else: put_in(acc[id], by)
  end
end
