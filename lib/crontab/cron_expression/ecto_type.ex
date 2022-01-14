# TODO: Replace with simple Code.ensure_compiled as soon as Elixir minimum
# version is raised to 1.10.

Code
|> function_exported?(:ensure_compiled, 1)
|> if do
  match?({:module, Ecto.Type}, Code.ensure_compiled(Ecto.Type))
else
  :erlang.apply(Code, :ensure_compiled?, [Ecto.Type])
end
|> if do
  defmodule Crontab.CronExpression.Ecto.Type do
    @moduledoc """
    Provides a type for Ecto usage.

    The underlying data type should be a map.

    ## Migration Example

        create table(:my_table) do
          add :schedule, :map
        end

    ## Schema Example

        schema "my_table" do
          field :schedule, Crontab.CronExpression.Ecto.Type
        end

    """

    alias Crontab.CronExpression
    alias Crontab.CronExpression.Composer
    alias Crontab.CronExpression.Parser

    @behaviour Ecto.Type

    @type map_expression :: %{
            extended: boolean,
            reboot: boolean,
            second: [CronExpression.value(Calendar.second())],
            minute: [CronExpression.value(Calendar.minute())],
            hour: [CronExpression.value(Calendar.second())],
            day: [CronExpression.value(Calendar.day())],
            month: [CronExpression.value(Calendar.month())],
            weekday: [CronExpression.value(Calendar.day_of_week())],
            year: [CronExpression.value(Calendar.year())]
          }

    @spec type :: :map
    def type, do: :map

    @spec cast(any) :: {:ok, CronExpression.t()} | :error
    def cast(cron_expression = %Crontab.CronExpression{}), do: {:ok, cron_expression}

    def cast(cron_expression) when is_binary(cron_expression) do
      cron_expression
      |> String.trim()
      |> Parser.parse()
      |> case do
        result = {:ok, _} -> result
        _ -> :error
      end
    end

    def cast(_), do: :error

    @spec load(any) :: {:ok, CronExpression.t()} | :error
    def load(%{"extended" => extended, "expression" => expression}) do
      load(%{extended: extended, expression: expression})
    end

    def load(%{extended: extended, expression: expression}) do
      case Parser.parse(expression, extended) do
        result = {:ok, _} -> result
        _ -> :error
      end
    end

    def load(_), do: :error

    @spec dump(any) :: {:ok, CronExpression.t()} | :error
    def dump(cron_expression = %CronExpression{extended: extended}) do
      {:ok, %{extended: extended, expression: Composer.compose(cron_expression)}}
    end

    def dump(_), do: :error

    def embed_as(_), do: :dump

    def equal?(term1, term2), do: term1 == term2
  end
end
