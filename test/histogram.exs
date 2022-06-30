# MIT License
#
# Copyright (c) 2019-2022 Knoxen
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule RandomPassword.Histogram.Test do
  use ExUnit.Case

  import RandomPassword.Test.Util

  test "position histogram: 1, 5, 2, alpha d of dingosky" do
    IO.write("Position of 'd' using 1, 5, 2 with alphas 'dingosky' ... ")

    defmodule(DefaultAlpha_1_5_2,
      do: use(RandomPassword, alpha: 1, decimal: 5, symbol: 2, alphas: "dingosky")
    )

    n_chars = DefaultAlpha_1_5_2.generate() |> String.length()

    trials = 200_000

    position_histogram_test(DefaultAlpha_1_5_2, "d", n_chars, trials)

    IO.puts("ok")
  end

  test "position histogram: 10, 1, 1, symbol ^ of *!%^#$_" do
    IO.write("Position of '^' using 10, 2, 1 with default symbols ... ")

    defmodule(Symbol_10_1_1,
      do: use(RandomPassword, alpha: 10, decimal: 2, symbol: 1)
    )

    n_chars = Symbol_10_1_1.info().symbols |> String.length()
    trials = 200_000

    position_histogram_test(Symbol_10_1_1, "^", n_chars, trials)

    IO.puts("ok")
  end

  test "positions histogram: 8, 2, 0, decimal chars" do
    IO.write("Position of decimal using 8, 2, 0 ... ")

    decimal = 2
    defmodule(Decimal_8_2_0, do: use(RandomPassword, alpha: 8, decimal: decimal))

    trials = 75_000
    positions_histogram_test(Decimal_8_2_0, "0123456789", decimal, trials)

    IO.puts("ok")
  end

  test "positions histogram: 10, 3, 2, decimal chars" do
    IO.write("Position of decimal using 10, 3, 2 ... ")

    decimal = 3
    defmodule(Decimal_10_3_2, do: use(RandomPassword, alpha: 10, decimal: decimal, symbol: 2))
    trials = 75_000
    positions_histogram_test(Decimal_10_3_2, "0123456789", decimal, trials)

    IO.puts("ok")
  end

  test "positions histogram: 8, 2, 4, symbol chars" do
    IO.write("Position of symbol using 8, 2, 4 ... ")

    symbol = 4
    defmodule(Symbol_8_2_4, do: use(RandomPassword, alpha: 8, decimal: 2, symbol: symbol))
    trials = 100_000
    positions_histogram_test(Symbol_8_2_4, Symbol_8_2_4.info().symbols, symbol, trials)

    IO.puts("ok")
  end

  test "positions histogram: 10, 2, 3, symbol of +,-./:;<=>" do
    IO.write("Position of symbol using 10, 3, 2, symbols +,-./:;<=> ... ")
    symbol = 3
    symbols = "+,-./:;<=>"

    defmodule(Symbol_10_2_4,
      do: use(RandomPassword, alpha: 10, decimal: 2, symbol: symbol, symbols: symbols)
    )

    trials = 100_000
    positions_histogram_test(Symbol_10_2_4, symbols, symbol, trials)

    IO.puts("ok")
  end
end
