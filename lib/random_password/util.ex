defmodule RandomPassword.Util do
  @moduledoc false
  @rand_u32_range Bitwise.bsl(1, 32)

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
  def validate_decimals(chars) do
    decimal = Puid.Chars.charlist!(:decimal)

    valid =
      chars
      |> to_charlist()
      |> Enum.reduce(true, fn char, valid -> valid and Enum.member?(decimal, char) end)

    if !valid, do: raise(RandomPassword.Error, "Invalid decimal character")

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

  @doc false
  def shuffle(charlist, rand_bytes \\ &:crypto.strong_rand_bytes/1)
  def shuffle(charlist, _rand_bytes) when length(charlist) < 2, do: charlist

  def shuffle(charlist, rand_bytes) do
    chars = List.to_tuple(charlist)

    chars
    |> fisher_yates_shuffle(tuple_size(chars) - 1, rand_bytes)
    |> Tuple.to_list()
  end

  defp fisher_yates_shuffle(chars, 0, _), do: chars

  defp fisher_yates_shuffle(chars, i, rand_bytes) do
    j = next_index(i + 1, rand_bytes)

    chars
    |> swap(i, j)
    |> fisher_yates_shuffle(i - 1, rand_bytes)
  end

  defp swap(chars, i, i), do: chars

  defp swap(chars, i, j) do
    i_char = elem(chars, i)
    j_char = elem(chars, j)

    chars
    |> put_elem(i, j_char)
    |> put_elem(j, i_char)
  end

  defp next_index(upper_bound, rand_bytes) do
    max_sample = div(@rand_u32_range, upper_bound) * upper_bound
    sample = rand_u32(rand_bytes)

    if sample < max_sample do
      rem(sample, upper_bound)
    else
      next_index(upper_bound, rand_bytes)
    end
  end

  defp rand_u32(rand_bytes) do
    <<sample::unsigned-big-integer-size(32)>> = rand_bytes.(4)
    sample
  end
end
