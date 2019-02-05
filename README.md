# RandomPassword

Efficiently generate cryptographically strong random passwords using alpha, numeric and special symbols.

[![Build Status](https://travis-ci.org/RandomPassword/Elixir.svg?branch=master)](https://travis-ci.org/RandomPassword/Elixir) &nbsp; [![Hex Version](https://img.shields.io/hexpm/v/RandomPassword.svg "Hex Version")](https://hex.pm/packages/random_password) &nbsp; [![License: MIT](https://img.shields.io/npm/l/express.svg)]()

## <a name="Installation"></a>Installation

Add `random_password` to `mix.exs` dependencies:

  ```elixir
  def deps,
    do: [ 
      {:random_password, "~> 1.0"}
    ]
  ```

Update dependencies

  ```bash
  mix deps.get
  ```

[TOC](#TOC)

## <a name="Usage"></a>Usage

Create a module for generating random passwords:

```elixir
  iex> defmodule(DefaultPassword, do: use(RandomPassword))
  iex> DefaultPassword.generate()
  "Uip5jNV%X6hEvRIgE"
```

By default, `RandomPassword` modules generate passwords of length 17, comprised of 14 alpha, 2 decimal, and 1 symbol. To specify different character counts, supply any combination of `alpha`, `decimal` or `symbol` during module creation:


```elixir
  iex> defmodule(StrongPassword, do: use(RandomPassword, alpha: 16, decimal: 4, symbol: 2))
  iex> StrongPassword.generate()
  "ghp0?HQ5|tl6AIbXSwGR7D"
```

A specific set of symbols can be specified using the `symbols` option:

```elixir
  iex> defmodule(CustomSymbolsPassword, do: use(RandomPassword, alpha: 12, symbol: 3, symbols: "@#$%&!"))
  iex> CustomSymbolsPassword.generate()
  "FM$sM#PRldXWEM$"
```

Each created module includes a `info/0` function to display module parameterization:

```elixir
  iex> StrongPassword.info()
  %RandomPassword.Info{
    alpha: 16,
    decimal: 4,
    entropy_bits: 114.11,
    length: 22,
    symbol: 2,
    symbols: "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  }
```

`info/0` output includes a calculation of bits of entropy for generated passwords. `RandomPassword.entropy_bits/3` can be used to calculate entropy bits. For example, using the parameters passed when creating `StrongPassword`, password entropy can determine **_before_** creating the module:

```elixir
  iex> RandomPassword.entropy_bits(16, 4, 2) |> Float.round(2)
  114.11
```


