# Getting Started
## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:crontab, "~> 1.1"}]
    end
    ```

  2. Ensure `crontab` is started before your application:

    ```elixir
    def application do
      [applications: [:crontab]]
    end
    ```

## Import cron expression sigil
Everywhere you want to use the cron expression sigil (`e[cron expression]`), import `Crontab.CronExpression`.

```elixir
import Crontab.CronExpression
```
