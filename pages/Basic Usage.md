# Basic Usage

## Extended Cron expressions

An extended cron expression has more precision than a normal cron expression. It also specifies the second.

If you want to use extended cron expressions with the sigil, just append an `e`.

## Checking if a Cron Expression Matches a date

```elixir
iex> import Crontab.CronExpression
iex> Crontab.DateChecker.matches_date?(~e[*/2], ~N[2017-01-01 01:01:00])
false
iex> Crontab.DateChecker.matches_date?(~e[*], ~N[2017-01-01 01:01:00])
true
```

## Find Next / Previous Execution Date candidates

All the date parameters default to now.

For previous, just replace `next` in the code below.

```elixir
iex> import Crontab.CronExpression
iex> Crontab.Scheduler.get_next_run_date(~e[*/2], ~N[2017-01-01 01:01:00])
{:ok, ~N[2017-01-01 01:02:00]}
iex> Crontab.Scheduler.get_next_run_date!(~e[*/2], ~N[2017-01-01 01:01:00])
{:ok, ~N[2017-01-01 01:02:00]}
```

```elixir
iex> Crontab.Scheduler.get_next_run_dates(3, ~e[*/2], ~N[2017-01-01 01:01:00])
{:ok,
 [~N[2017-01-01 01:02:00], ~N[2017-01-01 01:04:00], ~N[2017-01-01 01:06:00]]}
iex> Crontab.Scheduler.get_next_run_dates!(3, ~e[*/2], ~N[2017-01-01 01:01:00])
[~N[2017-01-01 01:02:00], ~N[2017-01-01 01:04:00], ~N[2017-01-01 01:06:00]]
```

## Parse Cron Expressions

If you statically define cron expressions, use the `~e[cron expression]` sigil.

For dynamic cron expressions, there is a Parser module.

The parser module takes an optional `extended` flag. This is to mark if the expression contains seconds.
This defaults to `false`.

```elixir
iex> Crontab.CronExpression.Parser.parse "* * * * *"
{:ok,
  %Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
  month: [:*], weekday: [:*], year: [:*]}}
iex> Crontab.CronExpression.Parser.parse! "* * * * *"
%Crontab.CronExpression{day: [:*], hour: [:*], minute: [:*],
 month: [:*], weekday: [:*], year: [:*]}
```

## Compose Cron expressions
```elixir
iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{}
"* * * * * *"
iex> Crontab.CronExpression.Composer.compose %Crontab.CronExpression{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
"9,4-6,*/9 * * * * *"
```
