defmodule Crontab.CronDateChecker do
  import Crontab.CronInterval

  @moduledoc """
  This Module is used to check a Crontab.CronInterval against a given date.
  """

  @doc """
  Check a Crontab.CronInterval against a given date.

  ### Examples
    iex> Crontab.CronDateChecker.matches_date :hour, [{:"/", 4}, 7], ~N[2004-04-16 04:07:08]
    true

    iex> Crontab.CronDateChecker.matches_date :hour, [8], ~N[2004-04-16 04:07:08]
    false

    iex> Crontab.CronDateChecker.matches_date %Crontab.CronInterval{minute: [{:"/", 8}]}, ~N[2004-04-16 04:08:08]
    true

    iex> Crontab.CronDateChecker.matches_date %Crontab.CronInterval{minute: [{:"/", 9}]}, ~N[2004-04-16 04:07:08]
    false
  """
  def matches_date(_, [:* | _], _), do: true
  def matches_date(_, [], _), do: false
  def matches_date(interval, [{:"/", divider} | tail], execution_date) do
    if rem(get_interval_value(interval, execution_date), divider) == 0 do
      true
    else
      matches_date(interval, tail, execution_date)
    end
  end
  def matches_date(interval, [number | tail], execution_date) when is_integer(number) do
    if get_interval_value(interval, execution_date) == number do
      true
    else
      matches_date(interval, tail, execution_date)
    end
  end
  def matches_date(cron_interval = %Crontab.CronInterval{}, execution_date) do
    cron_interval
      |> to_condition_list
      |> matches_date(execution_date)
  end
  def matches_date([], _), do: true
  def matches_date([{interval, conditions} | tail], execution_date) do
    matches_date(interval, conditions, execution_date) && matches_date(tail, execution_date)
  end

  defp get_interval_value(:minute, %NaiveDateTime{minute: minute}), do: minute
  defp get_interval_value(:hour, %NaiveDateTime{hour: hour}), do: hour
  defp get_interval_value(:day, %NaiveDateTime{day: day}), do: day
  defp get_interval_value(:weekday, %NaiveDateTime{year: year, month: month, day: day}), do: :calendar.day_of_the_week(year, month, day)
  defp get_interval_value(:month, %NaiveDateTime{month: month}), do: month
  defp get_interval_value(:year, %NaiveDateTime{year: year}), do: year
end
