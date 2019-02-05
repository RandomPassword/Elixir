defmodule RandomPassword.Error do
  @moduledoc """
  Errors raised when defining a RandomPassword module with invalid options
  """
  defexception message: "RandomPassword error"
end

defmodule RandomPassword.Defaults do
  @moduledoc """
  Defaults used when defining a RandomPassword module

    - alpha: 14
    - decimal: 2
    - symbol: 1
    - symbols: "!#$%&()*+,-./:;<=>?@[]^_{|}~"

  """
  defstruct alpha: 14,
            decimal: 2,
            symbol: 1,
            symbols: "!#$%&()*+,-./:;<=>?@[]^_{|}~"
end

defmodule RandomPassword.Info do
  @moduledoc false
  defstruct entropy_bits: 0,
            alpha: 0,
            decimal: 0,
            symbol: 0,
            symbols: "",
            length: 0
end

defmodule RandomPassword.Util do
  @moduledoc false

  @doc false
  def bits(n, charset), do: n * Puid.Entropy.bits_per_char!(charset)

  @doc false
  def puid_mod_name(mod, charset),
    do:
      "#{mod}.Puid.#{charset |> to_string() |> String.capitalize()}"
      |> String.to_atom()

  @doc false
  def gen_puid_charset_mod(mod, charset, 0, _) do
    mod_name =
      mod
      |> puid_mod_name(charset)

    defmodule mod_name do
      def generate, do: ""
      def info, do: "Empty string module"
    end
  end

  @doc false
  def gen_puid_charset_mod(mod, charset, n, nil),
    do:
      mod
      |> puid_mod_name(charset)
      |> defmodule(do: use(Puid, bits: RandomPassword.Util.bits(n, charset), charset: charset))

  @doc false
  def gen_puid_charset_mod(mod, charset, n, rand_bytes),
    do:
      mod
      |> puid_mod_name(charset)
      |> defmodule(
        do:
          use(Puid,
            bits: RandomPassword.Util.bits(n, charset),
            charset: charset,
            rand_bytes: rand_bytes
          )
      )

  @doc false
  def gen_puid_chars_mod(mod, _, 0, _) do
    mod_name =
      mod
      |> puid_mod_name(:symbol)

    defmodule mod_name do
      def generate, do: ""
      def info, do: "Empty string module"
    end
  end

  @doc false
  def gen_puid_chars_mod(mod, chars, n, nil),
    do:
      mod
      |> puid_mod_name(:symbol)
      |> defmodule(do: use(Puid, bits: RandomPassword.Util.bits(n, chars), chars: chars))

  @doc false
  def gen_puid_chars_mod(mod, chars, n, rand_bytes),
    do:
      mod
      |> puid_mod_name(:symbol)
      |> defmodule(
        do:
          use(Puid,
            bits: RandomPassword.Util.bits(n, chars),
            chars: chars,
            rand_bytes: rand_bytes
          )
      )
end

defmodule RandomPassword do
  @moduledoc """
  Random Password generator.

  `RandomPassword` creates a module for randomly generating strings with a specified number of
  alpha, decimal and symbol characters. Symbols can be optionally specified.

  """

  alias RandomPassword.Defaults
  alias RandomPassword.Util

  alias Puid.Entropy

  @doc """

  Bits of entropy for password with `alpha` alpha chars, `decimal` decimal digits and `symbol`
  chars using `symbols`, which defaults to "!#$%&()*+,-./:;<=>?@[]^_{|}~"

  This function provides calculation of entropy bits without having to create a module.

  ## Example

      iex> RandomPassword.entropy_bits(12, 4, 2) |> Float.round(2)
      91.31

      iex> RandomPassword.entropy_bits(12, 4, 2, "!@#$%&")  |> Float.round(2)
      86.86

  """
  def entropy_bits(
        alpha,
        decimal,
        symbol,
        symbols \\ %RandomPassword.Defaults{}.symbols()
      ) do
    cond do
      alpha < 0 ->
        raise RandomPassword.Error, "negative number of alpha chars"

      decimal < 0 ->
        raise RandomPassword.Error, "negative number of digit chars"

      symbol < 0 ->
        raise RandomPassword.Error, "negative number of symbol chars"

      true ->
        alpha * Entropy.bits_per_char!(:alpha) +
          decimal * Entropy.bits_per_char!(:decimal) +
          symbol * Entropy.bits_per_char!(symbols)
    end
  end

  defmacro __using__(opts) do
    quote do
      defaults = %Defaults{}

      opt_alpha = unquote(opts)[:alpha]
      opt_decimal = unquote(opts)[:decimal]
      opt_symbol = unquote(opts)[:symbol]

      {alpha, decimal, symbol} =
        if is_nil(opt_alpha) and is_nil(opt_decimal) and is_nil(opt_symbol),
          do: {
            defaults.alpha(),
            defaults.decimal(),
            defaults.symbol
          },
          else: {opt_alpha || 0, opt_decimal || 0, opt_symbol || 0}

      opt_symbols = unquote(opts)[:symbols]

      if !is_nil(opt_symbols) do
        alphas = Puid.CharSet.chars(:alpha)
        decimals = Puid.CharSet.chars(:decimal)

        if !is_binary(opt_symbols), do: raise(RandomPassword.Error, "symbols not a binary")

        opt_symbols
        |> String.graphemes()
        |> Enum.reduce(
          false,
          &(&2 || String.contains?(alphas, &1) || String.contains?(decimals, &1))
        )
        |> if do
          raise RandomPassword.Error, "symbols can't contain alpha or decimal"
        end
      end

      symbols = opt_symbols || defaults.symbols()

      rand_bytes = unquote(opts[:rand_bytes])

      cond do
        !is_integer(alpha) ->
          raise RandomPassword.Error, "alpha not an integer"

        !is_integer(decimal) ->
          raise RandomPassword.Error, "decimal not an integer"

        !is_integer(symbol) ->
          raise RandomPassword.Error, "symbol not an integer"

        alpha < 0 ->
          raise RandomPassword.Error, "negative number of alpha chars"

        decimal < 0 ->
          raise RandomPassword.Error, "negative number of digit chars"

        symbol < 0 ->
          raise RandomPassword.Error, "negative number of symbol chars"

        byte_size(symbols) < 2 ->
          raise RandomPassword.Error, "need at least 2 symbols"

        true ->
          :ok
      end

      @random_password_alpha alpha
      @random_password_decimal decimal
      @random_password_symbol symbol
      @random_password_size alpha + decimal + symbol
      @random_password_symbols symbols
      @random_password_entropy_bits RandomPassword.entropy_bits(
                                      alpha,
                                      decimal,
                                      symbol,
                                      symbols
                                    )
                                    |> Float.round(2)

      @random_password_bytes rand_bytes

      Util.gen_puid_charset_mod(
        __MODULE__,
        :alpha,
        @random_password_alpha,
        @random_password_bytes
      )

      Util.gen_puid_charset_mod(
        __MODULE__,
        :decimal,
        @random_password_decimal,
        @random_password_bytes
      )

      Util.gen_puid_chars_mod(
        __MODULE__,
        @random_password_symbols,
        @random_password_symbol,
        @random_password_bytes
      )

      defp generate(charset), do: (__MODULE__ |> Util.puid_mod_name(charset)).generate()

      @doc """
      Generate random password

      ## Example
          defmodule(Passwd, do: use(RandomPassword, alpha: 16, decimal: 4, symbol: 2))

          Passwd.generate()
          "vwt8FauEN+spr5{m1Rhso7"
      """

      def generate do
        shuffle =
          &if @random_password_bytes,
            do: CryptoRand.shuffle(&1, @random_password_bytes),
            else: CryptoRand.shuffle(&1)

        (generate(:symbol) <> generate(:decimal) <> generate(:alpha))
        |> shuffle.()
      end

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
      def info do
        %RandomPassword.Info{
          entropy_bits: @random_password_entropy_bits,
          alpha: @random_password_alpha,
          decimal: @random_password_decimal,
          symbol: @random_password_symbol,
          symbols: @random_password_symbols,
          length: @random_password_alpha + @random_password_decimal + @random_password_symbol
        }
      end
    end
  end
end
