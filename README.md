# Crontab

[![Build Status](https://travis-ci.org/sk-t/crontab.svg?branch=master)](https://travis-ci.org/sk-t/crontab)

Parse Cron Format Strings, Write Cron Format Strings and Caluclate Execution Dates.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

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
iex> Crontab.CronFormatWriter.write %Crontab.CronInterval{minute: [9, {:-, 4, 6}, {:/, 9}]}
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

iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{year: [{:/, 9}]}, ~N[2002-01-13 23:00:07])
{:ok, ~N[2007-01-01 00:00:00]}
```
