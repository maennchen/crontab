defmodule Crontab.CronScheduler do
  import Crontab.CronInterval
  import Crontab.CronDateChecker

  @moduledoc """
  This module provides the functionality to retrieve the next run date or the
  previous run date from a %Crontab.CronInterval{}.
  """

  @max_runs Application.get_env(:crontab, :max_runs, 10000)

  @doc """
  This function provides the functionality to retrieve the next run date from a
  %Crontab.CronInterval{}.

  ### Examples
    iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{}, ~N[2002-01-13 23:00:07])
    {:ok, ~N[2002-01-13 23:00:00]}

    iex> Crontab.CronScheduler.get_next_run_date(%Crontab.CronInterval{year: [{:/, 9}]}, ~N[2002-01-13 23:00:07])
    {:ok, ~N[2007-01-01 00:00:00]}
  """
  def get_next_run_date(cron_interval = %Crontab.CronInterval{}, date) do
    cron_interval
      |> to_condition_list
      |> get_next_run_date(reset(date, :seconds), @max_runs)
  end
  def get_next_run_date(conditions, date, max_runs) when max_runs > 0 do
    {status, corrected_date} = search_and_correct_date(conditions, date);
      #IO.puts "next"
      #IO.inspect corrected_date
    case status do
      :found -> {:ok, corrected_date}
      _ -> get_next_run_date(conditions, corrected_date, max_runs - 1)
    end
  end
  def get_next_run_date(_, _, 0) do
    {:error, "No compliant date was found for your interval."}
  end

  defp search_and_correct_date([{interval, conditions} | tail], date) do
    #IO.puts "search"
    #IO.inspect date
    if matches_date(interval, conditions, date) do
      search_and_correct_date(tail, date)
    else
      {:not_found, increment_date(interval, date)}
    end
  end
  defp search_and_correct_date([], date), do: {:found, date}

  defp increment_date(:minute, date), do: date |> Timex.shift(minutes: 1)
  defp increment_date(:hour, date), do: date |> Timex.shift(hours: 1) |> reset(:minutes)
  defp increment_date(:day, date), do: date |> Timex.shift(days: 1) |> Timex.beginning_of_day
  defp increment_date(:month, date), do: date |> Timex.shift(months: 1) |> Timex.beginning_of_month
  defp increment_date(:weekday, date), do: date |> Timex.shift(days: 1) |> Timex.beginning_of_day
  defp increment_date(:year, date), do: date |> Timex.shift(years: 1) |> Timex.beginning_of_year

  defp reset(date, :seconds), do: Timex.shift(date, seconds: 0 - date.second)
  defp reset(date, :minutes), do: date |> reset(:seconds) |> Timex.shift(minutes: 0 - date.minute)
end
