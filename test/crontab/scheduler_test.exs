defmodule Crontab.SchedulerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Crontab.Scheduler

  doctest Crontab.Scheduler

  test "check cron expression for year" do
    assert get_next_run_date(
             %Crontab.CronExpression{year: [{:/, :*, 9}]},
             ~N[2002-01-13 23:00:07]
           ) == {:ok, ~N[2007-01-01 00:00:00]}
  end

  test "check cron expression for weekday" do
    assert get_next_run_date(
             %Crontab.CronExpression{weekday: [{:/, :*, 3}]},
             ~N[2002-01-13 23:00:07]
           ) == {:ok, ~N[2002-01-16 00:00:00]}
  end

  test "check cron expression for month" do
    assert get_next_run_date(
             %Crontab.CronExpression{month: [{:/, :*, 9}]},
             ~N[2002-01-13 23:00:07]
           ) == {:ok, ~N[2002-09-01 00:00:00]}
  end

  test "check cron expression for day" do
    assert get_next_run_date(
             %Crontab.CronExpression{day: [{:/, :*, 16}]},
             ~N[2002-01-13 23:00:07]
           ) == {:ok, ~N[2002-01-16 00:00:00]}
  end

  test "check cron expression for hour" do
    assert get_next_run_date(%Crontab.CronExpression{hour: [16]}, ~N[2002-01-13 23:00:07]) ==
             {:ok, ~N[2002-01-14 16:00:00]}
  end

  test "check cron expression for minute" do
    assert get_next_run_date(%Crontab.CronExpression{minute: [16]}, ~N[2002-01-13 23:00:07]) ==
             {:ok, ~N[2002-01-13 23:16:00]}
  end

  test "check cron expression for second" do
    assert get_next_run_date(
             %Crontab.CronExpression{extended: true, second: [{:/, :*, 3}]},
             ~N[2002-01-13 23:00:06]
           ) == {:ok, ~N[2002-01-13 23:00:06]}
  end

  test "check cron expression given microseconds" do
    assert get_next_run_date(
             %Crontab.CronExpression{extended: true, second: [{:/, :*, 3}]},
             ~N[2002-01-13 23:00:06.00]
           ) == {:ok, ~N[2002-01-13 23:00:06]}
  end

  test "check combined" do
    assert get_next_run_date(
             %Crontab.CronExpression{minute: [3], hour: [7], day: [27], month: [2]},
             ~N[2002-01-13 23:00:07]
           ) == {:ok, ~N[2002-02-27 07:03:00]}
  end

  test "check run limits" do
    assert get_next_run_date(
             %Crontab.CronExpression{
               extended: true,
               second: [59],
               minute: [59],
               hour: [23],
               day: [31],
               month: [12],
               year: [9999]
             },
             ~N[1234-05-06 07:08:09]
           ) == {:ok, ~N[9999-12-31 23:59:59]}
  end

  test "check day occurrences in month" do
    assert get_next_run_date(
             %Crontab.CronExpression{minute: [0], hour: [9], weekday: [{:"#", 1, 1}]},
             ~N[2024-10-22 12:00:07]
           ) == {:ok, ~N[2024-11-04 09:00:00]}
  end

  test "check day occurrences in month for 5th time" do
    assert get_next_run_date(
             %Crontab.CronExpression{minute: [0], hour: [9], weekday: [{:"#", 1, 5}]},
             ~N[2024-10-22 12:00:07]
           ) == {:ok, ~N[2024-12-30 09:00:00]}
  end

  test "check for 5th occurrence of weekday backwards as well" do
    assert get_previous_run_date(
             %Crontab.CronExpression{minute: [0], hour: [9], weekday: [{:"#", 1, 5}]},
             ~N[2024-10-22 12:00:07]
           ) == {:ok, ~N[2024-09-30 09:00:00]}
  end
end
