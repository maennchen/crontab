# Crontab

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/sk-t/crontab/master/LICENSE)
[![Build Status](https://travis-ci.org/sk-t/crontab.svg?branch=master)](https://travis-ci.org/sk-t/crontab)
[![Hex.pm Version](https://img.shields.io/hexpm/v/crontab.svg?style=flat)](https://hex.pm/packages/crontab)
[![InchCI](https://inch-ci.org/github/sk-t/crontab.svg?branch=master)](https://inch-ci.org/github/sk-t/crontab)
[![Coverage Status](https://coveralls.io/repos/github/sk-t/crontab/badge.svg?branch=master)](https://coveralls.io/github/sk-t/crontab?branch=master)

Parse Cron Format Strings, Write Cron Format Strings and Caluclate Execution Dates.

## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:crontab, "~> 0.8.0"}]
    end
    ```

  2. Ensure `crontab` is started before your application:

    ```elixir
    def application do
      [applications: [:crontab]]
    end
    ```

## [Documentation](https://hexdocs.pm/crontab/)

## Usage

### Helper Functions

```elixir
iex> Crontab.get_next_run_date("* * * * *")
{:ok, ~N[2016-12-23 16:00:00.348751]}

iex> Crontab.get_next_run_date("* * * * *", ~N[2016-12-17 00:00:00])
{:ok, ~N[2016-12-17 00:00:00]}

iex> Crontab.get_next_run_dates(3, "* * * * *")
[{:ok, ~N[2016-12-23 16:00:00]},
 {:ok, ~N[2016-12-23 16:01:00]},
 {:ok, ~N[2016-12-23 16:02:00]}]

iex> Crontab.get_next_run_dates(3, "* * * * *", ~N[2016-12-17 00:00:00])
[{:ok, ~N[2016-12-17 00:00:00]},
 {:ok, ~N[2016-12-17 00:01:00]},
 {:ok, ~N[2016-12-17 00:02:00]}]

iex> Crontab.get_previous_run_date("* * * * *")
{:ok, ~N[2016-12-23 16:00:00.348751]}

iex> Crontab.get_previous_run_date("* * * * *", ~N[2016-12-17 00:00:00])
{:ok, ~N[2016-12-17 00:00:00]}

iex> Crontab.get_previous_run_dates(3, "* * * * *")
[{:ok, ~N[2016-12-23 16:00:00]},
 {:ok, ~N[2016-12-23 15:59:00]},
 {:ok, ~N[2016-12-23 15:58:00]}]

iex> Crontab.get_previous_run_dates(3, "* * * * *", ~N[2016-12-17 00:00:00])
[{:ok, ~N[2016-12-17 00:00:00]},
 {:ok, ~N[2016-12-16 23:59:00]},
 {:ok, ~N[2016-12-16 23:58:00]}]

iex> Crontab.matches_date("*/2 * * * *")
{:ok, true}

iex> Crontab.matches_date("*/7 * * * *")
{:ok, false}

iex> Crontab.matches_date("*/2 * * * *", ~N[2016-12-17 00:02:00])
{:ok, true}

iex> Crontab.matches_date("*/7 * * * *", ~N[2016-12-17 00:06:00])
{:ok, false}
```

### Parse Cron Format Strings
```elixir
iex> Crontab.CronFormatParser.parse "* * * * *"
{:ok,
  %Crontab.CronInterval{day: [:*], hour: [:*], minute: [:*],
  month: [:*], weekday: [:*], year: [:*]}}
iex> Crontab.CronFormatParser.parse "fooo"
{:error, "Can't parse fooo as interval minute."}
```

### Write Cron Format Strings
```elixir
iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{}
"* * * * * *"
iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{minute: [9, {:-, 4, 6}, {:/, :*, 9}]}
"9,4-6,*/9 * * * * *"
```

### Check if Cron Interval matches Date
```elixir
iex> Crontab.CronDateChecker.matches_date :hour, [{:"/", 4}, 7], ~N[2004-04-16 04:07:08]
true

iex> Crontab.CronDateChecker.matches_date :hour, [8], ~N[2004-04-16 04:07:08]
false

iex> Crontab.CronDateChecker.matches_date %Crontab.CronInterval{minute: [{:"/", 8}]}, ~N[2004-04-16 04:08:08]
true

iex> Crontab.CronDateChecker.matches_date %Crontab.CronInterval{minute: [{:"/", 9}]}, ~N[2004-04-16 04:07:08]
false
```

### Get next Running Day for Cron interval
```elixir
iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{}, ~N[2002-01-13 23:00:07])
{:ok, ~N[2002-01-13 23:00:00]}

iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{year: [{:/, :*, 9}]}, ~N[2002-01-13 23:00:07])
{:ok, ~N[2007-01-01 00:00:00]}
```
