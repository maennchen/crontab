# Crontab

[![CI](https://github.com/jshmrtn/crontab/workflows/.github/workflows/elixir.yml/badge.svg)](https://github.com/jshmrtn/crontab/actions?query=workflow%3A.github%2Fworkflows%2Felixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/crontab/badge.svg?branch=main)](https://coveralls.io/github/jshmrtn/crontab?branch=main)
[![Module Version](https://img.shields.io/hexpm/v/crontab.svg)](https://hex.pm/packages/crontab)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/crontab/)
[![Total Download](https://img.shields.io/hexpm/dt/crontab.svg)](https://hex.pm/packages/crontab)
[![License](https://img.shields.io/hexpm/l/crontab.svg)](https://github.com/jshmrtn/crontab/blob/main/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/jshmrtn/crontab.svg)](https://github.com/jshmrtn/crontab/commits/main)

Elixir library for parsing, writing, and calculating Cron format strings.

## Installation

Add `:crontab` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crontab, "~> 1.1"}
  ]
end
```

For Elixir version before 1.4, ensure `:crontab` is started before your
application:

```elixir
def application do
  [
    applications: [:crontab]
  ]
end
```

## Usage

### Import Cron expression sigil

Everywhere you want to use the Cron expression sigil (`e[cron expression]`).

```elixir
import Crontab.CronExpression
```

### Extended Cron expressions

An extended Cron expression has more precision than a normal Cron expression.
It also specifies the second.

If you want to use extended Cron expressions with the sigil, just append an `e`.

### Checking if a Cron Expression Matches a date

```elixir
iex> import Crontab.CronExpression
iex> Crontab.DateChecker.matches_date?(~e[*/2], ~N[2017-01-01 01:01:00])
false
iex> Crontab.DateChecker.matches_date?(~e[*], ~N[2017-01-01 01:01:00])
true
```

### Find Next / Previous Execution Date candidates

All the date parameters default to now.

For previous, just replace `next` in the code below.

```elixir
iex> import Crontab.CronExpression
iex> Crontab.Scheduler.get_next_run_date(~e[*/2], ~N[2017-01-01 01:01:00])
{:ok, ~N[2017-01-01 01:02:00]}
iex> Crontab.Scheduler.get_next_run_date!(~e[*/2], ~N[2017-01-01 01:01:00])
~N[2017-01-01 01:02:00]
```

```elixir
iex> Crontab.Scheduler.get_next_run_dates(3, ~e[*/2], ~N[2017-01-01 01:01:00])
{:ok,
 [~N[2017-01-01 01:02:00], ~N[2017-01-01 01:04:00], ~N[2017-01-01 01:06:00]]}
iex> Crontab.Scheduler.get_next_run_dates!(3, ~e[*/2], ~N[2017-01-01 01:01:00])
[~N[2017-01-01 01:02:00], ~N[2017-01-01 01:04:00], ~N[2017-01-01 01:06:00]]
```

### Parse Cron Expressions

If you statically define cron expressions, use the `~e[cron expression]` sigil.

For dynamic cron expressions, there is a Parser module.

The parser module takes an optional `extended` flag. This is to mark if the
expression contains seconds. This defaults to `false`.

```elixir
iex> Crontab.CronExpression.Parser.parse "* * * * *"
{:ok,
  %Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
  month: [:*], weekday: [:*], year: [:*]}}
iex> Crontab.CronExpression.Parser.parse! "* * * * *"
%Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
 month: [:*], weekday: [:*], year: [:*]}
```

### Compose Cron expressions

```elixir
iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{}
"* * * * * *"
iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
"9,4-6,*/9 * * * * *"
```

## Copyright and License

Copyright (c) 2016, SK & T AG, JOSHMARTIN GmbH, Jonatan Männchen

This library is MIT licensed. See the [LICENSE](https://github.com/jshmrtn/crontab/blob/main/LICENSE) for details.
