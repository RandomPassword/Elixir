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

Default __alpha__, __decimal__ and __symbol__ characters are used in creating passwords, but any set of unique characters (including Unicode for __alpha__) can be specified:

```elixir
  iex> alphas = "dđiînñgğoøsşkķyŷ"
  iex> decimals = "246789"
  iex> symbols = "@#$%&!"
  iex> defmodule(CustomCharsPassword, do: use(RandomPassword, alpha: 12, decimal: 3, symbol: 3, alphas: alphas, decimals: decimals, symbols: symbols))
  iex> CustomCharsPassword.generate()
  "9gn&ķ9ŷdksø@ğđ9kî$"
```

`RandomPassword` uses [:crypto.strong_rand_bytes/1](https://www.erlang.org/doc/man/crypto.html#strong_rand_bytes-1) as the default entropy source. The `rand_bytes` option can be used to specify any function of the form `(non_neg_integer) -> binary` as the source:

```elixir
  iex> defmodule(PrngPassword, do: use(RandomPassword, alpha: 14, decimal: 4, symbol: 3, rand_bytes: &:rand.bytes/1 ))
  iex> PrngPassword.generate()
  "em3wPy!EpI>65sBInC?s4"
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
      {:random_password, "~> 1.2"}
    ]
  ```

Update dependencies

  ```bash
  mix deps.get
  ```

[TOC](#TOC)

## <a name="Strategy"></a>Strategy

`RandomPassword` uses [`Puid`](https://hexdocs.pm/puid/Puid.html) to generate random strings. `Puid` is extremely fast, and by default using cryptographically strong random bytes for random string generation.

Three random strings are generated, one from each of `alphas`, `decimals` and `symbols` characters of length specified by the `alpha`, `decimal` and `symbol` options. These three strings are concatenated and shuffled to form the final random password.

Since `RandomPassword` restricts the optional characters for `alphas`, `decimals` and `symbols` to not overlap, the resulting entropy of the random password is the sum of the entropy for the three separate random strings. The `RandomPassword` module function `info/0` lists the total entropy bits of the generated random passwords.
