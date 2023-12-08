defmodule AdventOfCode.Day7 do
  def example_data() do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day7.part1(AdventOfCode.Day7.example_data())
      6440
  """
  def part1(input) do
    input
    |> Stream.map(&parse/1)
    |> Stream.map(fn {hand, bet} -> {kind(hand), hand, bet} end)
    |> Enum.sort()
    |> Stream.with_index(1)
    |> Stream.map(fn {{_, _, bet}, mul} -> bet * mul end)
    |> Enum.sum()
  end

  @doc """
  # Example 
      iex> AdventOfCode.Day7.part2(AdventOfCode.Day7.example_data())
      5905
  """

  def part2(input) do
    input
    |> Stream.map(&parse/1)
    |> Enum.map(fn {hand, bet} -> {wildify(hand, card_to_value(?J)), bet} end)
    |> Enum.map(fn {hand, bet} -> {kind_with_wild(hand), hand, bet} end)
    |> Enum.sort()
    |> Stream.with_index(1)
    |> Stream.map(fn {{_, _, bet}, mul} -> bet * mul end)
    |> Enum.sum()
  end

  defp wildify({a, b, c, d, e}, w) do
    Enum.map([a, b, c, d, e], fn card ->
      if card == w, do: 0, else: card
    end)
    |> List.to_tuple()
  end

  defp kind_with_wild({a, b, c, d, e}) when 0 in [a, b, c, d, e] do
    hand = [a, b, c, d, e]

    for p <- Enum.uniq(hand) do
      Enum.map(hand, &if(&1 == 0, do: p, else: &1))
      |> List.to_tuple()
    end
    |> Enum.map(&kind/1)
    |> Enum.max()
  end

  defp kind_with_wild(hand), do: kind(hand)

  # 5 of a kind
  defp kind({a, a, a, a, a}), do: 6
  # four of a kind
  defp kind({_, a, a, a, a}), do: 5
  defp kind({a, _, a, a, a}), do: 5
  defp kind({a, a, _, a, a}), do: 5
  defp kind({a, a, a, _, a}), do: 5
  defp kind({a, a, a, a, _}), do: 5
  # full house
  defp kind({a, a, a, b, b}), do: 4
  defp kind({a, a, b, a, b}), do: 4
  defp kind({a, a, b, b, a}), do: 4
  defp kind({a, b, a, a, b}), do: 4
  defp kind({a, b, a, b, a}), do: 4
  defp kind({a, b, b, a, a}), do: 4
  defp kind({b, a, a, a, b}), do: 4
  defp kind({b, a, a, b, a}), do: 4
  defp kind({b, a, b, a, a}), do: 4
  defp kind({b, b, a, a, a}), do: 4
  # three of a kind
  defp kind({a, a, a, _, _}), do: 3
  defp kind({a, a, _, a, _}), do: 3
  defp kind({a, a, _, _, a}), do: 3
  defp kind({a, _, a, a, _}), do: 3
  defp kind({a, _, a, _, a}), do: 3
  defp kind({a, _, _, a, a}), do: 3
  defp kind({_, a, a, a, _}), do: 3
  defp kind({_, a, a, _, a}), do: 3
  defp kind({_, a, _, a, a}), do: 3
  defp kind({_, _, a, a, a}), do: 3
  # two pair
  defp kind({a, a, b, b, _}), do: 2
  defp kind({a, a, b, _, b}), do: 2
  defp kind({a, a, _, b, b}), do: 2
  defp kind({a, b, a, b, _}), do: 2
  defp kind({a, b, a, _, b}), do: 2
  defp kind({a, _, a, b, b}), do: 2
  defp kind({a, b, b, a, _}), do: 2
  defp kind({a, b, _, a, b}), do: 2
  defp kind({a, _, b, a, b}), do: 2
  defp kind({a, b, b, _, a}), do: 2
  defp kind({a, b, _, b, a}), do: 2
  defp kind({a, _, b, b, a}), do: 2
  defp kind({_, a, a, b, b}), do: 2
  defp kind({_, a, b, a, b}), do: 2
  defp kind({_, a, b, b, a}), do: 2
  # one pair
  defp kind({a, a, _, _, _}), do: 1
  defp kind({a, _, a, _, _}), do: 1
  defp kind({a, _, _, a, _}), do: 1
  defp kind({a, _, _, _, a}), do: 1
  defp kind({_, a, a, _, _}), do: 1
  defp kind({_, a, _, a, _}), do: 1
  defp kind({_, a, _, _, a}), do: 1
  defp kind({_, _, a, a, _}), do: 1
  defp kind({_, _, a, _, a}), do: 1
  defp kind({_, _, _, a, a}), do: 1
  # high card
  defp kind(_), do: 0

  defp parse(<<a, b, c, d, e, ?\s, bid::binary>>) do
    hand = {
      card_to_value(a),
      card_to_value(b),
      card_to_value(c),
      card_to_value(d),
      card_to_value(e)
    }

    bid = String.to_integer(bid)
    {hand, bid}
  end

  defp card_to_value(c) when c in ?2..?9, do: c - ?0
  defp card_to_value(?T), do: 10
  defp card_to_value(?J), do: 11
  defp card_to_value(?Q), do: 12
  defp card_to_value(?K), do: 13
  defp card_to_value(?A), do: 14
end
