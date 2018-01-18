defmodule Crontab.SchedulerTest do
  use ExUnit.Case, async: true
  doctest Crontab.Scheduler
  import Crontab.Scheduler

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
end
