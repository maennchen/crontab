# Getting Started
## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:crontab, "~> 0.8.5"},
       {:timex, "~> 3.0"}]
    end
    ```

  2. Ensure `crontab` is started before your application:

    ```elixir
    def application do
      [applications: [:crontab, :timex]]
    end
    ```

## Import cron expression sigil
Everywhere you want to use the cron expression sigil (`e[cron expression]`), import `Crontab.CronExpression`.

```elixir
import Crontab.CronExpression
```
