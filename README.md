# Crontab

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
