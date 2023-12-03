defmodule AdventOfCode.Day2 do
  defmodule Set do
    defstruct red: 0, blue: 0, green: 0

    def subset(self, other) do
      self.red >= other.red and self.blue >= other.blue and self.green >= other.green
    end

    def max(sets) do
      Enum.reduce(sets, fn l, r ->
        %Set{
          red: max(l.red, r.red),
          green: max(l.green, r.green),
          blue: max(l.blue, r.blue)
        }
      end)
    end
  end

  defmodule Game do
    import NimbleParsec
    defstruct number: nil, sets: []

    cube =
      wrap(
        integer(min: 1)
        |> ignore(times(ascii_char([?\s]), min: 1))
        |> choice([
          replace(string("red"), :red),
          replace(string("green"), :green),
          replace(string("blue"), :blue)
        ])
      )

    set =
      wrap(
        concat(
          cube,
          repeat(
            ignore(string(","))
            |> ignore(repeat(ascii_char([?\s])))
            |> concat(cube)
          )
        )
      )

    game =
      ignore(string("Game "))
      |> integer(min: 1)
      |> ignore(string(":"))
      |> ignore(repeat(ascii_char([?\s])))
      |> concat(set)
      |> repeat(
        ignore(string(";"))
        |> ignore(repeat(ascii_char([?\s])))
        |> concat(set)
      )
      |> eos()

    defparsecp(:parser, game)

    def parse!(data) do
      case parse(data) do
        {:ok, result} -> result
        error -> raise error
      end
    end

    def parse(data) do
      with {:ok, [number | sets], _, _, _, _} <- parser(data) do
        sets =
          for set <- sets do
            Enum.reduce(set, %Set{}, fn
              [count, :red], set -> %Set{set | red: count}
              [count, :green], set -> %Set{set | green: count}
              [count, :blue], set -> %Set{set | blue: count}
            end)
          end

        {:ok, %__MODULE__{number: number, sets: sets}}
      end
    end
  end

  def example_data() do
    """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """
    |> String.split("\n")
    |> Stream.reject(&(&1 == ""))
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day2.part1(AdventOfCode.Day2.example_data())
      8
  """
  def part1(input) do
    max = %Set{red: 12, green: 13, blue: 14}

    input
    |> Stream.map(&Game.parse!/1)
    |> Stream.filter(fn game ->
      Enum.all?(game.sets, &Set.subset(max, &1))
    end)
    |> Stream.map(& &1.number)
    |> Enum.sum()
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day2.part2(AdventOfCode.Day2.example_data())
      2286
  """
  def part2(input) do
    input
    |> Stream.map(&Game.parse!/1)
    |> Stream.map(&Set.max(&1.sets))
    |> Stream.map(&(&1.red * &1.green * &1.blue))
    |> Enum.sum()
  end
end
