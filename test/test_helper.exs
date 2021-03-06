ExUnit.start()

defmodule RandomPassword.Test.Util do
  @moduledoc false

  use ExUnit.Case

  def position_histogram_test(mod, char, n_chars, trials) do
    histogram =
      1..trials
      |> Enum.reduce(%{}, fn _, map ->
        mod.generate()
        |> String.graphemes()
        |> Enum.find_index(&(&1 === char))
        |> case do
          nil ->
            map

          ndx ->
            Map.put(map, ndx, (map[ndx] || 0) + 1)
        end
      end)

    length = mod.info().length
    expect = trials / length / n_chars

    chi_square_test(histogram, chi_square(histogram, expect), length)
  end

  defp find_indexes(string, chars) when is_binary(string) and is_binary(chars),
    do:
      find_indexes(
        string
        |> String.graphemes(),
        chars
        |> String.graphemes()
      )

  defp find_indexes(str_list, char_list) do
    {_, ndxs} =
      str_list
      |> Enum.reduce({0, []}, fn char, {ndx, ndxs} ->
        next = ndx + 1
        if Enum.member?(char_list, char), do: {next, [ndx] ++ ndxs}, else: {next, ndxs}
      end)

    ndxs
  end

  def positions_histogram_test(mod, chars, n, trials) do
    histogram =
      1..trials
      |> Enum.reduce(%{}, fn _, map ->
        mod.generate()
        |> find_indexes(chars)
        |> Enum.reduce(map, &Map.put(&2, &1, (&2[&1] || 0) + 1))
      end)

    length = mod.info().length
    expect = n * trials / length

    chi_square_test(histogram, chi_square(histogram, expect), length)
  end

  def chi_square(histogram, expect) do
    histogram
    |> Enum.reduce(0, fn {_, value}, acc ->
      diff = value - expect
      acc + diff * diff / expect
    end)
  end

  def chi_square_test(histogram, chi_square, buckets) do
    deg_freedom = buckets - 1
    variance = :math.sqrt(2 * deg_freedom)
    n_sig = 4
    tolerance = n_sig * variance

    passed = chi_square < deg_freedom + tolerance and chi_square > deg_freedom - tolerance

    if !passed, do: IO.inspect(histogram, label: "\nFailed histogram")

    assert passed
  end

  def sample_histogram(trials, sample_fn) do
    1..trials
    |> Enum.reduce(%{}, fn _, map ->
      sample = sample_fn.()
      Map.put(map, sample, (map[sample] || 0) + 1)
    end)
  end
end
