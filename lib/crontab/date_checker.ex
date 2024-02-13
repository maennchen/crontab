defmodule Crontab.DateChecker do
  @moduledoc """
  This module is used to check a `Crontab.CronExpression` against a given date.
  """

  alias Crontab.CronExpression

  alias Crontab.DateHelper

  @type date :: NaiveDateTime.t() | DateTime.t()

  @doc """
  Check a condition list against a given date.

  ## Examples

      iex> Crontab.DateChecker.matches_date? %Crontab.CronExpression{minute: [{:"/", :*, 8}]}, ~N[2004-04-16 04:08:08]
      true

      iex> Crontab.DateChecker.matches_date? %Crontab.CronExpression{minute: [{:"/", :*, 9}]}, ~N[2004-04-16 04:07:08]
      false

      iex> Crontab.DateChecker.matches_date? %Crontab.CronExpression{reboot: true}, ~N[2004-04-16 04:07:08]
      ** (RuntimeError) Special identifier @reboot is not supported.

      iex> Crontab.DateChecker.matches_date? [{:hour, [{:"/", :*, 4}, 7]}], ~N[2004-04-16 04:07:08]
      true

  """
  @spec matches_date?(cron_expression :: CronExpression.t(), date :: date) ::
          boolean | no_return
  def matches_date?(cron_expression_or_condition_list, date)

  def matches_date?(%CronExpression{reboot: true}, _),
    do: raise("Special identifier @reboot is not supported.")

  def matches_date?(cron_expression = %CronExpression{}, execution_date) do
    cron_expression
    |> CronExpression.to_condition_list()
    |> matches_date?(execution_date)
  end

  @spec matches_date?(
          condition_list :: CronExpression.condition_list(),
          date :: date
        ) :: boolean
  def matches_date?([], _), do: true

  def matches_date?([{interval, conditions} | tail], execution_date) do
    matches_date?(interval, conditions, execution_date) && matches_date?(tail, execution_date)
  end

  @doc """
  Check a condition against a given date.

  ## Examples

      iex> Crontab.DateChecker.matches_date? :hour, [{:"/", :*, 4}, 7], ~N[2004-04-16 04:07:08]
      true

      iex> Crontab.DateChecker.matches_date? :hour, [8], ~N[2004-04-16 04:07:08]
      false

  """
  @spec matches_date?(
          interval :: CronExpression.interval(),
          condition_list :: CronExpression.condition_list(),
          date :: date
        ) :: boolean
  def matches_date?(_, [:* | _], _), do: true
  def matches_date?(_, [], _), do: false

  def matches_date?(interval, [condition | tail], execution_date) do
    values = get_interval_value(interval, execution_date)

    if matches_specific_date?(interval, values, condition, execution_date) do
      true
    else
      matches_date?(interval, tail, execution_date)
    end
  end

  @spec matches_specific_date?(
          interval :: CronExpression.interval(),
          values :: [CronExpression.time_unit()],
          condition :: CronExpression.value(),
          date :: date
        ) :: boolean
  defp matches_specific_date?(_, [], _, _), do: false
  defp matches_specific_date?(_, _, :*, _), do: true

  defp matches_specific_date?(
         interval,
         [head_value | tail_values],
         condition = {:-, from, to},
         execution_date
       ) do
    cond do
      from > to && (head_value >= from || head_value <= to) -> true
      from <= to && head_value >= from && head_value <= to -> true
      true -> matches_specific_date?(interval, tail_values, condition, execution_date)
    end
  end

  defp matches_specific_date?(:weekday, [0 | tail_values], condition = {:/, _, _}, execution_date) do
    matches_specific_date?(:weekday, tail_values, condition, execution_date)
  end

  defp matches_specific_date?(
         interval,
         values = [head_value | tail_values],
         condition = {:/, base = {:-, from, _}, divider},
         execution_date
       ) do
    if matches_specific_date?(interval, values, base, execution_date) &&
         rem(head_value - from, divider) == 0 do
      true
    else
      matches_specific_date?(interval, tail_values, condition, execution_date)
    end
  end

  defp matches_specific_date?(:day, [head_value | tail_values], :L, execution_date) do
    if DateHelper.end_of(execution_date, :month).day == head_value do
      true
    else
      matches_specific_date?(:day, tail_values, :L, execution_date)
    end
  end

  defp matches_specific_date?(:weekday, _, {:L, weekday}, execution_date) do
    DateHelper.last_weekday(execution_date, weekday) == execution_date.day
  end

  defp matches_specific_date?(:weekday, _, {:"#", weekday, n}, execution_date) do
    DateHelper.nth_weekday(execution_date, weekday, n) == execution_date.day
  end

  defp matches_specific_date?(:day, _, {:W, :L}, execution_date) do
    DateHelper.last_weekday_of_month(execution_date) === execution_date.day
  end

  defp matches_specific_date?(:day, _, {:W, day}, execution_date) do
    last_day = DateHelper.end_of(execution_date, :month).day

    specific_day =
      case last_day < day do
        true -> DateHelper.end_of(execution_date, :month)
        false -> Map.put(execution_date, :day, day)
      end

    DateHelper.next_weekday_to(specific_day) === execution_date.day
  end

  defp matches_specific_date?(
         interval,
         values = [head_value | tail_values],
         condition = {:/, base, divider},
         execution_date
       ) do
    if matches_specific_date?(interval, values, base, execution_date) &&
         rem(head_value, divider) == 0 do
      true
    else
      matches_specific_date?(interval, tail_values, condition, execution_date)
    end
  end

  defp matches_specific_date?(interval, [head_value | tail_values], number, execution_date)
       when is_integer(number) do
    if head_value == number do
      true
    else
      matches_specific_date?(interval, tail_values, number, execution_date)
    end
  end

  @spec get_interval_value(interval :: CronExpression.interval(), date :: date) :: [
          CronExpression.time_unit()
        ]
  defp get_interval_value(:second, %{second: second}), do: [second]
  defp get_interval_value(:minute, %{minute: minute}), do: [minute]
  defp get_interval_value(:hour, %{hour: hour}), do: [hour]
  defp get_interval_value(:day, %{day: day}), do: [day]

  defp get_interval_value(:weekday, %{year: year, month: month, day: day}) do
    day = :calendar.day_of_the_week(year, month, day)

    if day == 7 do
      [0, 7]
    else
      [day]
    end
  end

  defp get_interval_value(:month, %{month: month}), do: [month]
  defp get_interval_value(:year, %{year: year}), do: [year]
end
