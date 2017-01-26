if Code.ensure_compiled?(Ecto.Type) do
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
          field :schedule, CronExpression.Ecto.Type
        end

    """

    alias Crontab.CronExpression
    alias Crontab.CronExpression.Parser
    alias Crontab.CronExpression.Composer

    @behaviour Ecto.Type

    @type map_expression :: %{
      extended: boolean,
      reboot: boolean,
      second: [CronExpression.value],
      minute: [CronExpression.value],
      hour: [CronExpression.value],
      day: [CronExpression.value],
      month: [CronExpression.value],
      weekday: [CronExpression.value],
      year: [CronExpression.value]
    }

    @spec type :: :map
    def type, do: :map

    @spec cast(any) :: {:ok, CronExpression.t} | :error
    def cast(cron_expression = %Crontab.CronExpression{}), do: {:ok, cron_expression}
    def cast(cron_expression) when is_binary(cron_expression) do
      case Parser.parse(cron_expression) do
        result = {:ok, _} -> result
        _ -> :error
      end
    end
    def cast(_), do: :error

    @spec load(any) :: {:ok, CronExpression.t} | :error
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

    @spec dump(any) :: {:ok, CronExpression.t} | :error
    def dump(cron_expression = %CronExpression{extended: extended}) do
      {:ok, %{extended: extended, expression: Composer.compose(cron_expression)}}
    end
    def dump(_), do: :error
  end
end
