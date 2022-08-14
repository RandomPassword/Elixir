defmodule RandomPassword do
  @moduledoc """
  Random Password generator.

  `RandomPassword` creates a module for randomly generating strings with a specified number of
  alpha, decimal and symbol characters. Symbols can be optionally specified.

  """

  alias RandomPassword.Util

  alias Puid.Chars

  @doc """

  Bits of entropy for password with `alpha` alpha chars, `decimal` decimal digits and `symbol`
  symbol chars.

  This function provides calculation of entropy bits without having to create a module.

  The characters to be used for `alphas` and `symbols` can be specified as options; o/w defaults
  are used.

  ## Example

      iex> RandomPassword.entropy_bits(12, 4, 2) |> Float.round(2)
      91.31

      iex> RandomPassword.entropy_bits(12, 4, 2, symbols: "!@#$%&") |> Float.round(2)
      86.86

  """

  @spec entropy_bits(non_neg_integer, non_neg_integer, non_neg_integer, map()) :: float()
  def entropy_bits(alpha, decimal, symbol, options \\ %{}) do
    alphas = options[:alphas] || Util.chars_string(:alpha)
    symbols = options[:symbols] || Util.chars_string(:symbol)

    {alpha_bits, decimal_bits, symbol_bits} =
      entropy_bits(alpha, decimal, symbol, alphas, symbols)

    alpha_bits + decimal_bits + symbol_bits
  end

  @doc false
  def entropy_bits(alpha, decimal, symbol, alphas, symbols) do
    Util.validate_alpha(alphas)
    Util.validate_symbol(symbols)

    decimals = Util.chars_string(:decimal)

    Util.validate_n_chars(alpha, alphas)
    Util.validate_n_chars(decimal, decimals)
    Util.validate_n_chars(symbol, symbols)

    alpha_bits = Util.bits(alpha, alphas)
    decimal_bits = Util.bits(decimal, decimals)
    symbol_bits = Util.bits(symbol, symbols)

    {alpha_bits, decimal_bits, symbol_bits}
  end

  defmacro __using__(opts) do
    quote do
      default_alpha = Chars.charlist!(:alpha)
      default_symbol = Chars.charlist!(:symbol)

      {alpha, decimal, symbol} =
        Util.default_n(
          unquote(opts)[:alpha],
          unquote(opts)[:decimal],
          unquote(opts)[:symbol]
        )

      alphas = unquote(opts)[:alphas] || default_alpha |> to_string()
      decimals = Chars.charlist!(:decimal) |> to_string()
      symbols = unquote(opts)[:symbols] || default_symbol |> to_string()

      Util.validate_alpha(alphas)
      Util.validate_symbol(symbols)

      Util.validate_n_chars(alpha, alphas)
      Util.validate_n_chars(decimal, decimals)
      Util.validate_n_chars(symbol, symbols)

      rand_bytes = unquote(opts[:rand_bytes])

      {alpha_bits, decimal_bits, symbol_bits} =
        RandomPassword.entropy_bits(
          alpha,
          decimal,
          symbol,
          alphas,
          symbols
        )

      defmodule __MODULE__.Empty do
        def generate, do: ""
        def info, do: "Empty string module"
      end

      def_mod = fn mod_name, bits, chars, rand_bytes ->
        if 0 < bits do
          defmodule mod_name, do: use(Puid, bits: bits, chars: chars, rand_bytes: rand_bytes)
        else
          defmodule mod_name do
            def generate, do: ""
            def info, do: %Puid.Info{characters: ""}
          end
        end
      end

      def_mod.(__MODULE__.Alpha, alpha_bits, alphas, rand_bytes)

      def_mod.(__MODULE__.Decimal, decimal_bits, decimals, rand_bytes)

      def_mod.(__MODULE__.Symbol, symbol_bits, symbols, rand_bytes)

      @doc """
      Generate random password

      ## Example
          defmodule(Passwd, do: use(RandomPassword, alpha: 16, decimal: 4, symbol: 2))

          Passwd.generate()
          "vwt8FauEN+spr5{m1Rhso7"
      """

      def generate do
        alpha = __MODULE__.Alpha.generate()
        decimal = __MODULE__.Decimal.generate()
        symbol = __MODULE__.Symbol.generate()

        (alpha <> decimal <> symbol)
        |> to_charlist()
        |> Enum.shuffle()
        |> to_string()
      end

      mod_info = %RandomPassword.Info{
        entropy_bits: (alpha_bits + decimal_bits + symbol_bits) |> Float.round(2),
        alpha: alpha,
        decimal: decimal,
        symbol: symbol,
        alphas: __MODULE__.Alpha.info().characters(),
        decimals: __MODULE__.Decimal.info().characters(),
        symbols: __MODULE__.Symbol.info().characters(),
        length: alpha + decimal + symbol
      }

      @random_password_mod_info mod_info

      @doc """
      `RandomPassword` generated module info.

      ## Example
          defmodule(Password, do: use(RandomPassword, alpha: 16, decimal: 2, symbol: 1))

          Password.info()
              %RandomPassword.Info{
                alpha: 16,
                decimal: 2,
                entropy_bits: 102.66,
                symbol: 1,
                symbols: "!#$%&()*+,-./:;<=>?@[]^_{|}~"
              }
      """
      def info, do: @random_password_mod_info
    end
  end
end
