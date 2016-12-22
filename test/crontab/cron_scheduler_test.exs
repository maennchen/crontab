defmodule Crontab.CronSchedulerTest do
  use ExUnit.Case
  doctest Crontab.CronScheduler
  import Crontab.CronScheduler

  test "check cron expression for year" do
    assert get_next_run_date(%Crontab.CronInterval{year: [{:/, 9}]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2007-01-01 00:00:00]}
  end

  test "check cron expression for weekday" do
    assert get_next_run_date(%Crontab.CronInterval{weekday: [{:/, 3}]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-01-16 00:00:00]}
  end

  test "check cron expression for month" do
    assert get_next_run_date(%Crontab.CronInterval{month: [{:/, 9}]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-09-01 00:00:00]}
  end

  test "check cron expression for day" do
    assert get_next_run_date(%Crontab.CronInterval{day: [{:/, 16}]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-01-16 00:00:00]}
  end

  test "check cron expression for hour" do
    assert get_next_run_date(%Crontab.CronInterval{hour: [16]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-01-14 16:00:00]}
  end

  test "check cron expression for minute" do
    assert get_next_run_date(%Crontab.CronInterval{minute: [16]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-01-13 23:16:00]}
  end

  test "check combined" do
    assert get_next_run_date(%Crontab.CronInterval{minute: [3], hour: [7], day: [27], month: [2]}, ~N[2002-01-13 23:00:07]) == {:ok, ~N[2002-02-27 07:03:00]}
  end
end
