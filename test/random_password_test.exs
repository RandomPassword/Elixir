defmodule RandomPassword.Test do
  use ExUnit.Case

  alias RandomPassword.Util

  def no_module_default_chars(a, d, s, expect),
    do: assert(RandomPassword.entropy_bits(a, d, s) |> Float.round(2) === expect)

  test "entropy bits without module, default chars" do
    no_module_default_chars(16, 4, 2, 114.11)
    no_module_default_chars(16, 2, 0, 97.85)
    no_module_default_chars(16, 0, 2, 100.82)
    no_module_default_chars(16, 0, 0, 91.21)

    no_module_default_chars(0, 14, 2, 56.12)
    no_module_default_chars(0, 14, 0, 46.51)
    no_module_default_chars(0, 0, 14, 67.3)

    assert RandomPassword.entropy_bits(0, 0, 0) === 0
  end

  def no_module_default_chars(alphas \\ nil, symbols \\ nil, expect) do
    bits = RandomPassword.entropy_bits(12, 4, 2, alphas: alphas, symbols: symbols)
    assert bits |> Float.round(2) === expect
  end

  test "entropy bits without module, custom chars" do
    alphas = "dîngøsky"
    symbols = "!@#$%^&*()_+"
    no_module_default_chars(alphas, nil, 58.90)
    no_module_default_chars(alphas, symbols, 56.46)
    no_module_default_chars(nil, symbols, 88.86)
  end

  @tag :only
  test "entropy bits without module, invalid" do
    assert_raise RandomPassword.Error, fn ->
      RandomPassword.entropy_bits(12, 4, 2, alphas: "")
    end

    assert_raise Puid.Error, fn ->
      RandomPassword.entropy_bits(12, 4, 2, symbols: "#")
    end

    assert_raise RandomPassword.Error, fn ->
      RandomPassword.entropy_bits(12, 4, 2, alphas: "dîng0sky")
    end

    assert_raise RandomPassword.Error, fn ->
      RandomPassword.entropy_bits(12, 4, 2, symbols: "!@#$%^&*(ø)_+")
    end

    symbols = [?# | Puid.Chars.charlist!(:symbol)] |> to_string

    assert_raise RandomPassword.Error, fn ->
      RandomPassword.entropy_bits(12, 4, 2, symbols: symbols)
    end
  end

  def count_char_matchs(string, chars) do
    string
    |> String.graphemes()
    |> Enum.reduce(0, fn char, count ->
      if chars |> String.contains?(char), do: count + 1, else: count
    end)
  end

  def n_chars_test(alpha, decimal, symbol) do
    mod = "Password_#{alpha}_#{decimal}_#{symbol}" |> String.to_atom()

    defmodule(mod,
      do: use(RandomPassword, alpha: alpha, decimal: decimal, symbol: symbol)
    )

    mod_info = mod.info()

    assert mod_info.alpha === alpha
    assert mod_info.decimal === decimal
    assert mod_info.symbol === symbol
    assert mod_info.length === alpha + decimal + symbol
    assert mod_info.entropy_bits > 0

    password = mod.generate()
    assert is_binary(password)
    assert password |> String.length() === mod_info.length

    alphas = Util.chars_string(:alpha)
    decimals = Util.chars_string(:decimal)
    symbols = Util.chars_string(:symbol)

    assert count_char_matchs(password, alphas) === alpha
    assert count_char_matchs(password, decimals) === decimal
    assert count_char_matchs(password, symbols) === symbol
  end

  test "default module" do
    defmodule(DefaultPassword, do: use(RandomPassword))
    info = DefaultPassword.info()
    assert info.alpha === 14
    assert info.decimal === 2
    assert info.symbol === 1
    assert info.length === 17
    assert info.entropy_bits === 91.26
    assert DefaultPassword.generate() |> String.length() === info.length
  end

  test "password with explicit counts" do
    n_chars_test(10, 4, 2)
    n_chars_test(10, 4, 0)
    n_chars_test(10, 0, 2)
    n_chars_test(10, 0, 0)
    n_chars_test(0, 10, 2)
    n_chars_test(0, 10, 0)
    n_chars_test(0, 0, 10)
  end

  test "password with one specified count" do
    defmodule(Password_12_0_0, do: use(RandomPassword, alpha: 12))
    assert Password_12_0_0.info().alpha === 12
    assert Password_12_0_0.info().decimal === 0
    assert Password_12_0_0.info().symbol === 0

    defmodule(Password_0_8_0, do: use(RandomPassword, decimal: 8))
    assert Password_0_8_0.info().alpha === 0
    assert Password_0_8_0.info().decimal === 8
    assert Password_0_8_0.info().symbol === 0

    defmodule(Password_0_0_10, do: use(RandomPassword, symbol: 10))
    assert Password_0_0_10.info().alpha === 0
    assert Password_0_0_10.info().decimal === 0
    assert Password_0_0_10.info().symbol === 10
  end

  test "password with two specified counts" do
    defmodule(Password_14_2_0, do: use(RandomPassword, alpha: 16, decimal: 2))
    assert Password_14_2_0.info().alpha === 16
    assert Password_14_2_0.info().decimal === 2
    assert Password_14_2_0.info().symbol === 0

    defmodule(Password_10_0_8, do: use(RandomPassword, alpha: 10, symbol: 8))
    assert Password_10_0_8.info().alpha === 10
    assert Password_10_0_8.info().decimal === 0
    assert Password_10_0_8.info().symbol === 8

    defmodule(Password_0_10_8, do: use(RandomPassword, decimal: 10, symbol: 8))
    assert Password_0_10_8.info().alpha === 0
    assert Password_0_10_8.info().decimal === 10
    assert Password_0_10_8.info().symbol === 8
  end

  test "custom chars" do
    alphas = "dingosky"
    alpha = 10

    symbols = "@#$%^&*()_"
    symbol = 4

    defmodule(PasswordCustom,
      do:
        use(RandomPassword,
          alphas: alphas,
          alpha: alpha,
          symbols: symbols,
          symbol: symbol
        )
    )

    assert PasswordCustom.info().alpha === alpha
    assert PasswordCustom.info().alphas === alphas
    assert PasswordCustom.generate() |> count_char_matchs(alphas) === alpha

    assert PasswordCustom.info().symbol === symbol
    assert PasswordCustom.info().symbols === symbols
    assert PasswordCustom.generate() |> count_char_matchs(symbols) === symbol
  end

  test "unicode chars" do
    alphas = "dîñgøskyDÎÑGOß˚¥"
    alpha = 10

    defmodule(PasswordUnicode,
      do:
        use(RandomPassword,
          alphas: alphas,
          alpha: alpha
        )
    )

    assert PasswordUnicode.info().alpha === alpha
    assert PasswordUnicode.info().alphas === alphas
    assert PasswordUnicode.generate() |> count_char_matchs(alphas) === alpha
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

  test "alphas with decimal" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidAlpha, do: use(RandomPassword, alphas: "abcdefghijklmn0pq"))
    end
  end

  test "alphas with symbol" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidAlpha, do: use(RandomPassword, alphas: "abcdefghijklmnopqr$tuv"))
    end
  end

  test "alphas not unique" do
    assert_raise Puid.Error, fn ->
      defmodule(InvalidAlpha, do: use(RandomPassword, alphas: "dingoskydog"))
    end
  end

  test "alphas with invalid ascii" do
    assert_raise Puid.Error, fn ->
      defmodule(InvalidAscii, do: use(RandomPassword, alphas: "dingo sky"))
    end
  end

  test "symbols with decimal" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidSymbols, do: use(RandomPassword, symbols: "!@#$%6&"))
    end
  end

  test "symbols with alpha" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(InvalidSymbols, do: use(RandomPassword, symbols: "!@#$D%&"))
    end
  end

  test "symbols not unique" do
    assert_raise Puid.Error, fn ->
      defmodule(InvalidSymbols, do: use(RandomPassword, symbols: "!@#$%!&"))
    end
  end

  test "0 alpha" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(SingleAlpha, do: use(RandomPassword, alphas: ""))
    end
  end

  test "only 1 alpha" do
    assert_raise Puid.Error, fn ->
      defmodule(SingleAlpha, do: use(RandomPassword, alphas: "d"))
    end
  end

  test "0 symbol" do
    assert_raise RandomPassword.Error, fn ->
      defmodule(SingleAlpha, do: use(RandomPassword, symbols: ""))
    end
  end

  test "only 1 symbol" do
    assert_raise Puid.Error, fn ->
      defmodule(SingleSymbol, do: use(RandomPassword, symbols: "!"))
    end
  end
end
