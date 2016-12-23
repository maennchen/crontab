defmodule Crontab.CronScheduler do
  import Crontab.CronDateChecker

  @type direction :: :increment | :decrement
  @type result :: {:error, any} | {:ok, NaiveDateTime.t}

  @moduledoc """
  This module provides the functionality to retrieve the next run date or the
  previous run date from a `%Crontab.CronInterval{}`.
  """

  @max_runs Application.get_env(:crontab, :max_runs, 10000)

  @doc """
  This function provides the functionality to retrieve the next run date from a
  `%Crontab.CronInterval{}`.

  ### Examples
      iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{}, ~N[2002-01-13 23:00:07])
      {:ok, ~N[2002-01-13 23:00:00]}

      iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{year: [{:/, :*, 9}]}, ~N[2002-01-13 23:00:07])
      {:ok, ~N[2007-01-01 00:00:00]}
  """
  @spec get_next_run_date(Crontab.ExtendedCronInterval.all_t, NaiveDateTime.t) :: result
  def get_next_run_date(cron_interval, date), do: get_next_run_date(cron_interval, date, @max_runs)
  @spec get_next_run_date(Crontab.ExtendedCronInterval.all_t, NaiveDateTime.t, integer) :: result
  def get_next_run_date(cron_interval = %Crontab.CronInterval{}, date, max_runs) do
    get_run_date(cron_interval, date, max_runs, :increment)
  end
  def get_next_run_date(cron_interval = %Crontab.ExtendedCronInterval{}, date, max_runs) do
    get_run_date(cron_interval, date, max_runs, :increment)
  end


  @doc """
  This function provides the functionality to retrieve the previous run date
  from a `%Crontab.CronInterval{}`.

  ### Examples
      iex> Crontab.CronScheduler.get_previous_run_date(%Crontab.CronInterval{}, ~N[2002-01-13 23:00:07])
      {:ok, ~N[2002-01-13 23:00:00]}

      iex> Crontab.CronScheduler.get_previous_run_date(%Crontab.CronInterval{year: [{:/, :*, 9}]}, ~N[2002-01-13 23:00:07])
      {:ok, ~N[1998-12-31 23:59:00]}
  """
  @spec get_previous_run_date(Crontab.ExtendedCronInterval.all_t, NaiveDateTime.t) :: result
  def get_previous_run_date(cron_interval, date), do: get_previous_run_date(cron_interval, date, @max_runs)
  @spec get_previous_run_date(Crontab.ExtendedCronInterval.all_t, NaiveDateTime.t, integer) :: result
  def get_previous_run_date(cron_interval = %Crontab.CronInterval{}, date, max_runs) do
    get_run_date(cron_interval, date, max_runs, :decrement)
  end
  def get_previous_run_date(cron_interval = %Crontab.ExtendedCronInterval{}, date, max_runs) do
    get_run_date(cron_interval, date, max_runs, :decrement)
  end

  @spec get_run_date(Crontab.ExtendedCronInterval.all_t | Crontab.ExtendedCronInterval.condition_list, NaiveDateTime.t, integer, direction) :: result
  defp get_run_date(_, _, 0, _) do
    {:error, "No compliant date was found for your interval."}
  end
  defp get_run_date(cron_interval = %Crontab.CronInterval{}, date, max_runs, direction) do
    cron_interval
      |> Crontab.CronInterval.to_condition_list
      |> get_run_date(reset(date, :seconds), max_runs, direction)
  end
  defp get_run_date(cron_interval = %Crontab.ExtendedCronInterval{}, date, max_runs, direction) do
    cron_interval
      |> Crontab.ExtendedCronInterval.to_condition_list
      |> get_run_date(reset(date, :microseconds), max_runs, direction)
  end
  defp get_run_date(conditions, date, max_runs, direction) do
    {status, corrected_date} = search_and_correct_date(conditions, date, direction);
    case status do
      :found -> {:ok, corrected_date}
      _ -> get_run_date(conditions, corrected_date, max_runs - 1, direction)
    end
  end

  @spec search_and_correct_date(Crontab.ExtendedCronInterval.condition_list, NaiveDateTime.t, direction) :: NaiveDateTime.t | {:not_found, NaiveDateTime.t}
  defp search_and_correct_date([{interval, conditions} | tail], date, direction) do
    if matches_date(interval, conditions, date) do
      search_and_correct_date(tail, date, direction)
    else
      case correct_date(interval, date, direction) do
        # Prevent to reach lower bound (year 0)
        {:error, _} -> {:not_found, date}
        corrected_date -> {:not_found, corrected_date}
      end
    end
  end
  defp search_and_correct_date([], date, _), do: {:found, date}

  @spec correct_date(Crontab.CronInterval.interval, NaiveDateTime.t, direction) :: NaiveDateTime.t | {:error, any}

  defp correct_date(:second, date, :increment), do: date |> Timex.shift(seconds: 1)
  defp correct_date(:minute, date, :increment), do: date |> Timex.shift(minutes: 1) |> reset(:seconds)
  defp correct_date(:hour, date, :increment), do: date |> Timex.shift(hours: 1) |> reset(:minutes)
  defp correct_date(:day, date, :increment), do: date |> Timex.shift(days: 1) |> Timex.beginning_of_day
  defp correct_date(:month, date, :increment), do: date |> Timex.shift(months: 1) |> Timex.beginning_of_month
  defp correct_date(:weekday, date, :increment), do: date |> Timex.shift(days: 1) |> Timex.beginning_of_day
  defp correct_date(:year, date, :increment), do: date |> Timex.shift(years: 1) |> Timex.beginning_of_year

  defp correct_date(:second, date, :decrement), do: date |> Timex.shift(seconds: -1)
  defp correct_date(:minute, date, :decrement), do: date |> reset(:seconds) |> Timex.shift(minutes: -1)
  defp correct_date(:hour, date, :decrement), do: date |> reset(:minutes) |> Timex.shift(minutes: -1)
  defp correct_date(:day, date, :decrement), do: date |> Timex.beginning_of_day |> Timex.shift(minutes: -1)
  defp correct_date(:month, date, :decrement), do: date |> Timex.beginning_of_month |> Timex.shift(minutes: -1)
  defp correct_date(:weekday, date, :decrement), do: date |> Timex.beginning_of_day |> Timex.shift(minutes: -1)
  defp correct_date(:year, date, :decrement), do: date |> Timex.beginning_of_year |> Timex.shift(minutes: -1)

  @spec reset(NaiveDateTime.t, :microseconds | :seconds | :minutes) :: NaiveDateTime.t
  defp reset(date = %NaiveDateTime{}, :microseconds), do: Map.put(date, :microsecond, {0,0})
  defp reset(date = %NaiveDateTime{second: second}, :seconds), do: date |> reset(:microseconds) |> Timex.shift(seconds: 0 - second)
  defp reset(date = %NaiveDateTime{minute: minute}, :minutes), do: date |> reset(:seconds) |> Timex.shift(minutes: 0 - minute)
end
