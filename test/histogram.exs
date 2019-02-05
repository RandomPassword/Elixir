defmodule RandomPassword.Histogram.Test do
  use ExUnit.Case

  import RandomPassword.Test.Util

  test "position histogram: 8, 2, 1, symbol $ of #$" do
    defmodule(Symbol_8_2_1,
      do: use(RandomPassword, alpha: 8, decimal: 2, symbol: 1, symbols: "#$")
    )

    n_chars = Symbol_8_2_1.info().symbols |> String.length()
    trials = 100_000

    position_histogram_test(Symbol_8_2_1, "$", n_chars, trials)
  end

  test "position histogram: 10, 1, 1, symbol ^ of *!%^#$_" do
    defmodule(Symbol_10_1_1,
      do: use(RandomPassword, alpha: 8, decimal: 1, symbol: 1, symbols: "*!%^#$_")
    )

    n_chars = Symbol_10_1_1.info().symbols |> String.length()
    trials = 100_000

    position_histogram_test(Symbol_10_1_1, "^", n_chars, trials)
  end

  test "position histogram: 10, 1, 0, decimal 5" do
    defmodule(Decimal_10_1_0, do: use(RandomPassword, alpha: 10, decimal: 1))

    n_chars = 10
    trials = 100_000

    position_histogram_test(Decimal_10_1_0, "5", n_chars, trials)
  end

  test "positions histogram: 10, 2, 0, decimal chars" do
    decimal = 2
    defmodule(Decimal_8_2_0, do: use(RandomPassword, alpha: 8, decimal: decimal))

    trials = 75_000
    positions_histogram_test(Decimal_8_2_0, "0123456789", decimal, trials)
  end

  test "positions histogram: 10, 3, 2, decimal chars" do
    decimal = 3
    defmodule(Decimal_10_3_2, do: use(RandomPassword, alpha: 10, decimal: decimal, symbol: 2))
    trials = 75_000
    positions_histogram_test(Decimal_10_3_2, "0123456789", decimal, trials)
  end

  test "positions histogram: 8, 2, 4, symbol chars" do
    symbol = 4
    defmodule(Symbol_8_2_4, do: use(RandomPassword, alpha: 8, decimal: 2, symbol: symbol))
    trials = 100_000
    positions_histogram_test(Symbol_8_2_4, Symbol_8_2_4.info().symbols, symbol, trials)
  end

  test "positions histogram: 10, 2, 3, symbol of +,-./:;<=>" do
    symbol = 3
    symbols = "+,-./:;<=>"

    defmodule(Symbol_10_2_4,
      do: use(RandomPassword, alpha: 10, decimal: 2, symbol: symbol, symbols: symbols)
    )

    trials = 100_000
    positions_histogram_test(Symbol_10_2_4, symbols, symbol, trials)
  end

  test "positions histogram: 12, 2, 2, alpha" do
    alpha = 12

    defmodule(Alpha_12_2_2, do: use(RandomPassword, alpha: alpha, decimal: 2, symbol: 2))

    trials = 50_000
    alphas = Alpha_12_2_2.Puid.Alpha.info().chars
    positions_histogram_test(Alpha_12_2_2, alphas, alpha, trials)
  end
end
