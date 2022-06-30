# RandomPassword

Efficiently generate cryptographically strong random passwords using alpha (including Unicode), decimal and symbol characters.

[![Build Status](https://travis-ci.org/RandomPassword/Elixir.svg?branch=master)](https://travis-ci.org/RandomPassword/Elixir) &nbsp; [![Hex Version](https://img.shields.io/hexpm/v/random_password.svg "Hex Version")](https://hex.pm/packages/random_password) &nbsp; [![License: MIT](https://img.shields.io/npm/l/express.svg)]()


## <a name="TOC"></a>TOC
- [Usage](#Usage)
- [Installation](#Installation)
- [Strategy](#Strategy)

## <a name="Usage"></a>Usage

Create a module for generating random passwords:

```elixir
  iex> defmodule(DefaultPassword, do: use(RandomPassword))
  iex> DefaultPassword.generate()
  "Uip5jNV%X6hEvRIgE"
```

By default, `RandomPassword` modules generate passwords comprised of 14 alpha, 2 decimal, and 1 symbol. To specify different character counts, supply any combination of `alpha`, `decimal` or `symbol` during module creation:

```elixir
  iex> defmodule(StrongPassword, do: use(RandomPassword, alpha: 16, decimal: 4, symbol: 2))
  iex> StrongPassword.generate()
  "ghp0?HQ5|tl6AIbXSwGR7D"
```

Default __alpha__ characters are uppercase (A-Z) and lowercase (a-z) ascii. Any set of unique characters (including Unicode) can be specified:

```elixir
  iex> alphas = "dđiînñgğoøsşkķyŷ"
  iex> defmodule(CustomAlphaPassword, do: use(RandomPassword, alpha: 12, symbol: 3, alphas: alphas))
  iex> CustomAlphaPassword.generate()
  "#ñđdğdo_ŷ}oîiñķ"
```

Symbol characters can also be explicitly specified:

```elixir
  iex> defmodule(CustomSymbolsPassword, do: use(RandomPassword, alpha: 10, decimal: 3, symbol: 3, symbols: "@#$%&!"))
  iex> CustomSymbolsPassword.generate()
  "2e5@jfB&@sw4wvCF"
```

Each created module includes an `info/0` function to display module parameterization:

```elixir
  iex> defmodule(StrongPassword, do: use(RandomPassword, alpha: 17, decimal: 3, symbol: 3))
  iex> StrongPassword.generate()
  "d{ItIFZ76ads;u8cQbhPjg#"
  iex> StrongPassword.info()
  %RandomPassword.Info{
    alpha: 17,
    alphas: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
    decimal: 3,
    decimals: "0123456789",
    entropy_bits: 121.3,
    length: 23,
    symbol: 3,
    symbols: "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  }
```

## <a name="Installation"></a>Installation

Add `random_password` to `mix.exs` dependencies:

  ```elixir
  def deps,
    do: [ 
      {:random_password, "~> 1.1"}
    ]
  ```

Update dependencies

  ```bash
  mix deps.get
  ```

[TOC](#TOC)

## <a name="Strategy"></a>Strategy

`RandomPassword` uses [`Puid`](https://hexdocs.pm/puid/Puid.html) to generate random strings. `Puid` is extremely fast, and by default using cryptographically strong random bytes for random string generation.

Three random strings are generated, one from each of `alphas`, __decimal__ and `symbols` characters of length specified by the `alpha`, `decimal` and `symbol` options. These three strings are concatenated and shuffled to form the final random password.

Since `RandomPassword` restricts the optional setting of `alphas` and `symbols` characters to not overlap with either each other or the fixed __decimal__ characters, the resulting entropy of the random password is the sum of the entropy for the three separate random strings. The `RandomPassword` module function `info/0` lists the total entropy bits of the generated random passwords.
