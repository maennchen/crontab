# Crontab

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/sk-t/crontab/master/LICENSE)
[![Build Status](https://travis-ci.org/sk-t/crontab.svg?branch=master)](https://travis-ci.org/sk-t/crontab)
[![Hex.pm Version](https://img.shields.io/hexpm/v/crontab.svg?style=flat)](https://hex.pm/packages/crontab)
[![InchCI](https://inch-ci.org/github/sk-t/crontab.svg?branch=master)](https://inch-ci.org/github/sk-t/crontab)
[![Coverage Status](https://coveralls.io/repos/github/sk-t/crontab/badge.svg?branch=master)](https://coveralls.io/github/sk-t/crontab?branch=master)

Parse Cron Format Strings, Write Cron Format Strings and Caluclate Execution Dates.

## Roadmap
 * Support cron expressions including seconds
 * Support `W` modifier

## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:crontab, "~> 0.1.0"}]
    end
    ```

  2. Ensure `crontab` is started before your application:

    ```elixir
    def application do
      [applications: [:crontab]]
    end
    ```

## Unsupported Features
The 'W' character is allowed for the day-of-month field. This character is used to specify the weekday (Monday-Friday) nearest the given day. As an example, if you were to specify "15W" as the value for the day-of-month field, the meaning is: "the nearest weekday to the 15th of the month". So if the 15th is a Saturday, the trigger will fire on Friday the 14th. If the 15th is a Sunday, the trigger will fire on Monday the 16th. If the 15th is a Tuesday, then it will fire on Tuesday the 15th. However if you specify "1W" as the value for day-of-month, and the 1st is a Saturday, the trigger will fire on Monday the 3rd, as it will not 'jump' over the boundary of a month's days. The 'W' character can only be specified when the day-of-month is a single day, not a range or list of days.

The 'L' and 'W' characters can also be combined for the day-of-month expression to yield 'LW', which translates to "last weekday of the month".

## Usage

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
