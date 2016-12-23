defmodule Crontab.FunctionalTest do
  use ExUnit.Case

  tests_find_date = [
    {"*/2 */2 * * *", ~N[2015-08-10 21:47:27], ~N[2015-08-10 22:00:00], false},
    {"* * * * *", ~N[2015-08-10 21:50:37], ~N[2015-08-10 21:50:00], true},
    {"* 20,21,22 * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00], true},
    # Handles CSV values
    {"* 20,22 * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 22:00:00], false},
    # CSV values can be complex
    {"* 5,21-22 * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00], true},
    {"7-9 * */9 * *", ~N[2015-08-10 22:02:33], ~N[2015-08-18 00:07:00], false},
    # 15th minute, of the second hour, every 15 days, in January, every Friday
    {"1 * * * 7", ~N[2015-08-10 21:47:27], ~N[2015-08-16 00:01:00], false},
    # Test with exact times
    {"47 21 * * *", ~N[2015-08-10 21:47:30], ~N[2015-08-10 21:47:00], true},
    # Test Day of the week (issue #1)
    # According cron implementation, 0|7 = sunday, 1 => monday, etc
    {"* * * * 0", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"* * * * 7", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"* * * * 1", ~N[2011-06-15 23:09:00], ~N[2011-06-20 00:00:00], false},
    # Should return the sunday date as 7 equals 0
    {"0 0 * * MON,SUN", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"0 0 * * 1,7", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"0 0 * * 0-4", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], false},
    {"0 0 * * 7-4", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], false},
    {"0 0 * * 4-7", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], false},
    {"0 0 * * 7-3", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"0 0 * * 3-7", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], false},
    {"0 0 * * 3-7", ~N[2011-06-18 23:09:00], ~N[2011-06-19 00:00:00], false},
    # Test lists of values and ranges (Abhoryo)
    {"0 0 * * 2-7", ~N[2011-06-20 23:09:00], ~N[2011-06-21 00:00:00], false},
    {"0 0 * * 0,2-6", ~N[2011-06-20 23:09:00], ~N[2011-06-21 00:00:00], false},
    {"0 0 * * 2-7", ~N[2011-06-18 23:09:00], ~N[2011-06-19 00:00:00], false},
    {"0 0 * * 4-7", ~N[2011-07-19 00:00:00], ~N[2011-07-21 00:00:00], false},
    # Test increments of ranges
    {"0-12/4 * * * *", ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00], true},
    {"4-59/2 * * * *", ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00], true},
    {"4-59/2 * * * *", ~N[2011-06-20 12:06:00], ~N[2011-06-20 12:06:00], true},
    {"4-59/3 * * * *", ~N[2011-06-20 12:06:00], ~N[2011-06-20 12:07:00], false},
    # Test Day of the Week and the Day of the Month (issue #1)
    {"0 0 1 1 0", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], false},
    {"0 0 1 JAN 0", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], false},
    {"0 0 1 * 0", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], false},
    {"0 0 L * *", ~N[2011-07-15 00:00:00], ~N[2011-07-31 00:00:00], false},
    # Test the W day of the week modifier for day of the month field
    # {"0 0 2W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    # {"0 0 1W * *", ~N[2011-05-01 00:00:00], ~N[2011-05-02 00:00:00], false},
    # {"0 0 1W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    # {"0 0 3W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-04 00:00:00], false},
    # {"0 0 16W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-15 00:00:00], false},
    # {"0 0 28W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-28 00:00:00], false},
    # {"0 0 30W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], false},
    # {"0 0 31W * *", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], false},
    # Test the year field
    {"* * * * * 2012", ~N[2011-05-01 00:00:00], ~N[2012-01-01 00:00:00], false},
    # Test the last weekday of a month
    {"* * * * 5L", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], false},
    {"* * * * 6L", ~N[2011-07-01 00:00:00], ~N[2011-07-30 00:00:00], false},
    {"* * * * 7L", ~N[2011-07-01 00:00:00], ~N[2011-07-31 00:00:00], false},
    {"* * * * 1L", ~N[2011-07-24 00:00:00], ~N[2011-07-25 00:00:00], false},
    {"* * * * TUEL", ~N[2011-07-24 00:00:00], ~N[2011-07-26 00:00:00], false},
    {"* * * 1 5L", ~N[2011-12-25 00:00:00], ~N[2012-01-27 00:00:00], false},
    # Test the last day of a month
    {"* * L", ~N[2011-07-01 00:00:00], ~N[2011-07-31 00:00:00], false},
    # Test the last day of a week
    {"* * * * L", ~N[2011-07-01 00:00:00], ~N[2011-07-03 00:00:00], false},
    # Test the last month of a day
    {"* * * L", ~N[2011-07-01 00:00:00], ~N[2011-12-01 00:00:00], false},
    # # Test the hash symbol for the nth weekday of a given month
    {"* * * * 5#2", ~N[2011-07-01 00:00:00], ~N[2011-07-08 00:00:00], false},
    {"* * * * 5#1", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    {"* * * * 3#4", ~N[2011-07-01 00:00:00], ~N[2011-07-27 00:00:00], false},
  ]

  for {cron_expression, start_date, search_date, matches_now} <- tests_find_date do
    @cron_expression cron_expression
    @start_date start_date
    @search_date search_date
    @matches_now matches_now
    test "test " <> @cron_expression <> " from " <> NaiveDateTime.to_iso8601(@start_date) <> " equals " <> NaiveDateTime.to_iso8601(@search_date) do
      {:ok, cron_interval} = Crontab.CronFormatParser.parse(@cron_expression)
      assert Crontab.CronScheduler.get_next_run_date(cron_interval, @start_date) == {:ok, @search_date}
      assert Crontab.CronDateChecker.matches_date(cron_interval, @start_date) == @matches_now
    end
  end
end
