defmodule RandomPassword.Test do
  use ExUnit.Case

  def count_char_matchs(string, chars) do
    string
    |> String.graphemes()
    |> Enum.reduce(0, fn char, count ->
      if String.contains?(chars, char), do: count + 1, else: count
    end)
  end

  def password_test(alpha, decimal, symbol) do
    mod = "Password_#{alpha}_#{decimal}_#{symbol}" |> String.to_atom()
    defmodule(mod, do: use(RandomPassword, alpha: alpha, decimal: decimal, symbol: symbol))

    assert mod.info.alpha === alpha
    assert mod.info.decimal === decimal
    assert mod.info.symbol === symbol
    assert mod.info.length === alpha + decimal + symbol
    assert mod.info.entropy_bits > 0

    password = mod.generate()
    assert is_binary(password)
    assert password |> String.length() === mod.info.length

    alphas =
      (?a..?z |> Enum.to_list() |> to_string()) <> (?A..?Z |> Enum.to_list() |> to_string())

    assert count_char_matchs(password, alphas) === alpha
    assert count_char_matchs(password, "0123456789") === decimal
  end

  test "password module explicit counts" do
    password_test(10, 4, 2)
    password_test(10, 4, 0)
    password_test(10, 0, 2)
    password_test(10, 0, 0)
    password_test(0, 10, 2)
    password_test(0, 10, 0)
    password_test(0, 0, 10)
  end

  test "default module info" do
    defmodule(DefaultPassword, do: use(RandomPassword))
    assert DefaultPassword.info().alpha === 14
    assert DefaultPassword.info().decimal === 2
    assert DefaultPassword.info().symbol === 1
    assert DefaultPassword.info().length === 17
    assert DefaultPassword.info().entropy_bits === 91.26
  end

  test "password module alpha default counts" do
    defmodule(Password_14_0_0, do: use(RandomPassword, alpha: 14))
    assert Password_14_0_0.info().alpha === 14
    assert Password_14_0_0.info().decimal === 0
    assert Password_14_0_0.info().symbol === 0

    defmodule(Password_14_2_0, do: use(RandomPassword, alpha: 14, decimal: 2))
    assert Password_14_2_0.info().alpha === 14
    assert Password_14_2_0.info().decimal === 2
    assert Password_14_2_0.info().symbol === 0

    defmodule(Password_14_0_2, do: use(RandomPassword, alpha: 14, symbol: 2))
    assert Password_14_0_2.info().alpha === 14
    assert Password_14_0_2.info().decimal === 0
    assert Password_14_0_2.info().symbol === 2
  end

  test "password module decimal default counts" do
    defmodule(Password_0_14_0, do: use(RandomPassword, decimal: 14))
    assert Password_0_14_0.info().alpha === 0
    assert Password_0_14_0.info().decimal === 14
    assert Password_0_14_0.info().symbol === 0

    defmodule(Password_0_14_2, do: use(RandomPassword, decimal: 14, symbol: 2))
    assert Password_0_14_2.info().alpha === 0
    assert Password_0_14_2.info().decimal === 14
    assert Password_0_14_2.info().symbol === 2
  end

  test "password module symbol default counts" do
    defmodule(Password_0_0_11, do: use(RandomPassword, symbol: 11))
    assert Password_0_0_11.info().alpha === 0
    assert Password_0_0_11.info().decimal === 0
    assert Password_0_0_11.info().symbol === 11
  end

  test "invalid counts" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidAlpha, do: use(RandomPassword, alpha: 2.5))
    end

    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidDecimal, do: use(RandomPassword, decimal: -1))
    end

    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidSymbol, do: use(RandomPassword, symbol: -1.1))
    end
  end

  test "symbols not binary" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidSymbols, do: use(RandomPassword, symbols: '!@#$%6&'))
    end
  end

  test "symbols with decimal char" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidSymbols, do: use(RandomPassword, symbols: "!@#$%6&"))
    end
  end

  test "only 1 symbol" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(SingleSymbol, do: use(RandomPassword, symbols: "!"))
    end
  end

  test "symbols not unique" do
    assert_raise Puid.Error, fn ->
      defmodule(RepeatSymbol, do: use(RandomPassword, symbols: "!@#$%^#*"))
    end
  end
end
