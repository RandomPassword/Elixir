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

defmodule RandomPassword.Util do
  @moduledoc false

  @doc false
  def bits(0, _), do: 0
  def bits(n, chars), do: n * Puid.Entropy.bits_per_char!(chars)

  def chars_string(chars), do: chars |> Puid.Chars.charlist!() |> to_string()

  def default_n(nil, nil, nil), do: {14, 2, 1}
  def default_n(a, d, s), do: {a || 0, d || 0, s || 0}

  @doc false
  def validate_alpha(chars) do
    decimal = Puid.Chars.charlist!(:decimal)
    symbol = Puid.Chars.charlist!(:symbol)

    valid =
      chars
      |> to_charlist()
      |> Enum.reduce(true, fn char, valid ->
        valid and !Enum.member?(decimal, char) and !Enum.member?(symbol, char)
      end)

    if !valid, do: raise(RandomPassword.Error, "Invalid alpha character")

    :ok
  end

  @doc false
  def validate_symbol(chars) do
    symbol = Puid.Chars.charlist!(:symbol)

    if length(symbol) < String.length(chars),
      do: raise(RandomPassword.Error, "Invalid symbol character")

    valid =
      chars
      |> to_charlist()
      |> Enum.reduce(true, fn char, valid -> valid and Enum.member?(symbol, char) end)

    if !valid, do: raise(RandomPassword.Error, "Invalid symbol character")

    :ok
  end

  @doc false
  def validate_n_chars(n, _) when n < 0,
    do: raise(RandomPassword.Error, "Cannot specify negative number characters")

  def validate_n_chars(0, _), do: :ok

  def validate_n_chars(n, "") when 0 < n,
    do: raise(RandomPassword.Error, "Cannot specify number of characters when characters empty")

  def validate_n_chars(n, _) when is_integer(n), do: :ok

  def validate_n_chars(_, _),
    do: raise(RandomPassword.Error, "Specified number of characters is not an integer")
end
