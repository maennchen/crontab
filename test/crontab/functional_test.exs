defmodule Crontab.FunctionalTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Crontab.CronExpression.Composer
  alias Crontab.CronExpression.Parser

  tests_find_date = [
    # {To Parse, To Compose, Relative Date, Next Search Date, Previous Search Date, Matches Now}
    {"*/2 */2 * * *", "*/2 */2 * * * *", ~N[2015-08-10 21:47:27], ~N[2015-08-10 22:00:00], ~N[2015-08-10 20:58:00],
     false},
    {"* * * * *", "* * * * * *", ~N[2015-08-10 21:50:37], ~N[2015-08-10 21:51:00], ~N[2015-08-10 21:50:00], true},
    {"* 20,21,22 * * *", "* 20,21,22 * * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00],
     true},
    # Handles CSV values
    {"* 20,22 * * *", "* 20,22 * * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 22:00:00], ~N[2015-08-10 20:59:00],
     false},
    # CSV values can be complex
    {"* 5,21-22 * * *", "* 5,21-22 * * * *", ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00], ~N[2015-08-10 21:50:00],
     true},
    {"7-9 * */9 * *", "7-9 * */9 * * *", ~N[2015-08-10 22:02:33], ~N[2015-08-18 00:07:00], ~N[2015-08-09 23:09:00],
     false},
    # 15th minute, of the second hour, every 15 days, in January, every Friday
    {"1 * * * 7", "1 * * * 7 *", ~N[2015-08-10 21:47:27], ~N[2015-08-16 00:01:00], ~N[2015-08-09 23:01:00], false},
    # Test with exact times
    {"47 21 * * *", "47 21 * * * *", ~N[2015-08-10 21:47:30], ~N[2015-08-11 21:47:00], ~N[2015-08-10 21:47:00], true},
    # Test Day of the week (issue #1)
    # According cron implementation, 0|7 = sunday, 1 => monday, etc
    {"* * * * 0", "* * * * 0 *", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-12 23:59:00], false},
    {"* * * * 7", "* * * * 7 *", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-12 23:59:00], false},
    {"* * * * 1", "* * * * 1 *", ~N[2011-06-15 23:09:00], ~N[2011-06-20 00:00:00], ~N[2011-06-13 23:59:00], false},
    # Should return the sunday date as 7 equals 0
    {"0 0 * * MON,SUN", "0 0 * * 1,7 *", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-13 00:00:00],
     false},
    {"0 0 * * 1,7", "0 0 * * 1,7 *", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-13 00:00:00], false},
    {"0 0 * * 0-4", "0 0 * * 0-4 *", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], ~N[2011-06-15 00:00:00], false},
    {"0 0 * * 7-4", "0 0 * * 7-4 *", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], ~N[2011-06-15 00:00:00], false},
    {"0 0 * * 4-7", "0 0 * * 4-7 *", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], ~N[2011-06-12 00:00:00], false},
    {"0 0 * * 7-3", "0 0 * * 7-3 *", ~N[2011-06-15 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-15 00:00:00], false},
    {"0 0 * * 3-7", "0 0 * * 3-7 *", ~N[2011-06-15 23:09:00], ~N[2011-06-16 00:00:00], ~N[2011-06-15 00:00:00], false},
    {"0 0 * * 3-7", "0 0 * * 3-7 *", ~N[2011-06-18 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-18 00:00:00], false},
    # Test lists of values and ranges (Abhoryo)
    {"0 0 * * 2-7", "0 0 * * 2-7 *", ~N[2011-06-20 23:09:00], ~N[2011-06-21 00:00:00], ~N[2011-06-19 00:00:00], false},
    {"0 0 * * 0,2-6", "0 0 * * 0,2-6 *", ~N[2011-06-20 23:09:00], ~N[2011-06-21 00:00:00], ~N[2011-06-19 00:00:00],
     false},
    {"0 0 * * 2-7", "0 0 * * 2-7 *", ~N[2011-06-18 23:09:00], ~N[2011-06-19 00:00:00], ~N[2011-06-18 00:00:00], false},
    {"0 0 * * 4-7", "0 0 * * 4-7 *", ~N[2011-07-19 00:00:00], ~N[2011-07-21 00:00:00], ~N[2011-07-17 00:00:00], false},
    # Test increments of ranges
    {"0-12/4 * * * *", "0-12/4 * * * * *", ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00],
     true},
    {"4-59/2 * * * *", "4-59/2 * * * * *", ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00], ~N[2011-06-20 12:04:00],
     true},
    {"4-59/2 * * * *", "4-59/2 * * * * *", ~N[2011-06-20 12:06:00], ~N[2011-06-20 12:06:00], ~N[2011-06-20 12:06:00],
     true},
    {"4-59/3 * * * *", "4-59/3 * * * * *", ~N[2011-06-20 12:06:00], ~N[2011-06-20 12:07:00], ~N[2011-06-20 12:04:00],
     false},
    # Test Day of the Week and the Day of the Month (issue #1)
    {"0 0 1 1 0", "0 0 1 1 0 *", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], ~N[2006-01-01 00:00:00], false},
    {"0 0 1 JAN 0", "0 0 1 1 0 *", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], ~N[2006-01-01 00:00:00], false},
    {"0 0 1 * 0", "0 0 1 * 0 *", ~N[2011-06-15 23:09:00], ~N[2012-01-01 00:00:00], ~N[2011-05-01 00:00:00], false},
    {"0 0 L * *", "0 0 L * * *", ~N[2011-07-15 00:00:00], ~N[2011-07-31 00:00:00], ~N[2011-06-30 00:00:00], false},
    # Test the W day of the week modifier for day of the month field
    {"0 0 LW * *", "0 0 LW * * *", ~N[2016-12-24 00:00:00], ~N[2016-12-30 00:00:00], ~N[2016-11-30 00:00:00], false},
    {"0 0 2W * *", "0 0 2W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    {"0 0 1W * *", "0 0 1W * * *", ~N[2011-05-01 00:00:00], ~N[2011-05-02 00:00:00], ~N[2011-04-01 00:00:00], false},
    {"0 0 1W * *", "0 0 1W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    {"0 0 3W * *", "0 0 3W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-04 00:00:00], ~N[2011-06-03 00:00:00], false},
    {"0 0 16W * *", "0 0 16W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-15 00:00:00], ~N[2011-06-16 00:00:00], false},
    {"0 0 28W * *", "0 0 28W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-28 00:00:00], ~N[2011-06-28 00:00:00], false},
    {"0 0 30W * *", "0 0 30W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], ~N[2011-06-30 00:00:00], false},
    {"0 0 31W * *", "0 0 31W * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], ~N[2011-06-30 00:00:00], false},
    # Test the year field
    {"* * * * * 2012", "* * * * * 2012", ~N[2011-05-01 00:00:00], ~N[2012-01-01 00:00:00], :none, false},
    # Test the last weekday of a month
    {"* * * * 5L", "* * * * 5L *", ~N[2011-07-01 00:00:00], ~N[2011-07-29 00:00:00], ~N[2011-06-24 23:59:00], false},
    {"* * * * 6L", "* * * * 6L *", ~N[2011-07-01 00:00:00], ~N[2011-07-30 00:00:00], ~N[2011-06-25 23:59:00], false},
    {"* * * * 7L", "* * * * 7L *", ~N[2011-07-01 00:00:00], ~N[2011-07-31 00:00:00], ~N[2011-06-26 23:59:00], false},
    {"* * * * 1L", "* * * * 1L *", ~N[2011-07-24 00:00:00], ~N[2011-07-25 00:00:00], ~N[2011-06-27 23:59:00], false},
    {"* * * * TUEL", "* * * * 2L *", ~N[2011-07-24 00:00:00], ~N[2011-07-26 00:00:00], ~N[2011-06-28 23:59:00], false},
    {"* * * 1 5L", "* * * 1 5L *", ~N[2011-12-25 00:00:00], ~N[2012-01-27 00:00:00], ~N[2011-01-28 23:59:00], false},
    # Test the last day of a month
    {"* * L", "* * L * * *", ~N[2011-07-01 00:00:00], ~N[2011-07-31 00:00:00], ~N[2011-06-30 23:59:00], false},
    # Test the last day of a week
    {"* * * * L", "* * * * 7 *", ~N[2011-07-01 00:00:00], ~N[2011-07-03 00:00:00], ~N[2011-06-26 23:59:00], false},
    # Test the last month of a year
    {"* * * L", "* * * 12 * *", ~N[2011-07-01 00:00:00], ~N[2011-12-01 00:00:00], ~N[2010-12-31 23:59:00], false},
    # # Test the hash symbol for the nth weekday of a given month
    {"* * * * 5#2", "* * * * 5#2 *", ~N[2011-07-01 00:00:00], ~N[2011-07-08 00:00:00], ~N[2011-06-10 23:59:00], false},
    {"* * * * 5#1", "* * * * 5#1 *", ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], ~N[2011-07-01 00:00:00], true},
    {"* * * * 3#4", "* * * * 3#4 *", ~N[2011-07-01 00:00:00], ~N[2011-07-27 00:00:00], ~N[2011-06-22 23:59:00], false},
    {"0 9 * * mon#5", "0 9 * * 1#5 *", ~N[2024-10-22 09:00:00], ~N[2024-12-30 09:00:00], ~N[2024-09-30 09:00:00], false}
  ]

  for {cron_expression, written_cron_expression, start_date, next_search_date, previous_search_date, matches_now} <-
        tests_find_date do
    @cron_expression cron_expression
    @written_cron_expression written_cron_expression
    @start_date start_date
    @next_search_date next_search_date
    @previous_search_date previous_search_date
    @matches_now matches_now
    test "test " <>
           @cron_expression <>
           " from " <>
           NaiveDateTime.to_iso8601(@start_date) <>
           " equals " <> NaiveDateTime.to_iso8601(@next_search_date) do
      {:ok, cron_expression} = Parser.parse(@cron_expression)
      assert Composer.compose(cron_expression) == @written_cron_expression

      assert {:ok, next_search_date} =
               Crontab.Scheduler.get_next_run_date(cron_expression, @start_date)

      assert Crontab.DateChecker.matches_date?(cron_expression, next_search_date)

      assert next_search_date == @next_search_date

      case @previous_search_date do
        :none ->
          assert Crontab.Scheduler.get_previous_run_date(cron_expression, @start_date) ==
                   {:error, "No compliant date was found for your interval."}

        _ ->
          assert {:ok, previous_search_date} =
                   Crontab.Scheduler.get_previous_run_date(cron_expression, @start_date)

          assert Crontab.DateChecker.matches_date?(cron_expression, previous_search_date)

          assert previous_search_date == @previous_search_date
      end

      assert Crontab.DateChecker.matches_date?(cron_expression, @start_date) == @matches_now
    end
  end

  tests_find_date_extended = [
    # {To Parse, To Compose, Relative Date, Next Search Date, Previous Search Date, Matches Now}
    {"*/2 */2 * * * *", "*/2 */2 * * * * *", ~N[2015-08-10 21:47:27], ~N[2015-08-10 21:48:00], ~N[2015-08-10 21:46:58],
     false},
    {"* * * * *", "* * * * * * *", ~N[2015-08-10 21:50:37], ~N[2015-08-10 21:50:37], ~N[2015-08-10 21:50:37], true},
    {"* * * * * * *", "* * * * * * *", ~N[2015-08-10 21:50:37.2], ~N[2015-08-10 21:50:38], ~N[2015-08-10 21:50:37], true},
    {"*/4 * * * *", "*/4 * * * * * *", ~N[2016-12-17 00:00:03], ~N[2016-12-17 00:00:04], ~N[2016-12-17 00:00:00], false}
  ]

  for {cron_expression, written_cron_expression, start_date, next_search_date, previous_search_date, matches_now} <-
        tests_find_date_extended do
    @cron_expression cron_expression
    @written_cron_expression written_cron_expression
    @start_date start_date
    @next_search_date next_search_date
    @previous_search_date previous_search_date
    @matches_now matches_now
    test "extended test " <>
           @cron_expression <>
           " from " <>
           NaiveDateTime.to_iso8601(@start_date) <>
           " equals " <> NaiveDateTime.to_iso8601(@next_search_date) do
      {:ok, cron_expression} = Parser.parse(@cron_expression, true)
      assert Composer.compose(cron_expression) == @written_cron_expression

      assert Crontab.Scheduler.get_next_run_date(cron_expression, @start_date) ==
               {:ok, @next_search_date}

      case @previous_search_date do
        :none ->
          assert Crontab.Scheduler.get_previous_run_date(cron_expression, @start_date) ==
                   {:error, "No compliant date was found for your interval."}

        _ ->
          assert Crontab.Scheduler.get_previous_run_date(cron_expression, @start_date) ==
                   {:ok, @previous_search_date}
      end

      assert Crontab.DateChecker.matches_date?(cron_expression, @start_date) == @matches_now
    end
  end

  tests_find_date_tz_changes = [
    # DST Shift with extra hour
    {"30 2 * * *", [:prior], "Europe/Zurich", ~N[2024-10-27 01:00:01],
     ["2024-10-27T02:30:00+02:00", "2024-10-28T02:30:00+01:00"]},
    {"30 2 * * *", [:subsequent], "Europe/Zurich", ~N[2024-10-27 01:00:01],
     ["2024-10-27T02:30:00+01:00", "2024-10-28T02:30:00+01:00"]},
    {"30 2 * * *", [:prior, :subsequent], "Europe/Zurich", ~N[2024-10-27 01:00:01],
     ["2024-10-27T02:30:00+02:00", "2024-10-27T02:30:00+01:00", "2024-10-28T02:30:00+01:00"]},
    {"30 2 * * *", [], "Europe/Zurich", ~N[2024-10-27 01:00:01], ["2024-10-28T02:30:00+01:00"]},

    # DST Shift with missing hour
    {"30 2 * * *", [:prior], "Europe/Zurich", ~N[2024-03-31 01:00:01], ["2024-04-01T02:30:00+02:00"]},
    {"30 2 * * *", [:subsequent], "Europe/Zurich", ~N[2024-03-31 01:00:01], ["2024-04-01T02:30:00+02:00"]},
    {"30 2 * * *", [:prior, :subsequent], "Europe/Zurich", ~N[2024-03-31 01:00:01], ["2024-04-01T02:30:00+02:00"]},
    {"30 2 * * *", [], "Europe/Zurich", ~N[2024-03-31 01:00:01], ["2024-04-01T02:30:00+02:00"]},

    # Half Hour Shift
    {"*/30", [:prior], "Australia/Lord_Howe", ~N[2024-04-07 01:15:01],
     ["2024-04-07T01:30:00+11:00", "2024-04-07T02:00:00+10:30"]},
    {"*/30", [:subsequent], "Australia/Lord_Howe", ~N[2024-04-07 01:15:01],
     ["2024-04-07T01:30:00+10:30", "2024-04-07T02:00:00+10:30"]},
    {"*/30", [:prior, :subsequent], "Australia/Lord_Howe", ~N[2024-04-07 01:15:01],
     ["2024-04-07T01:30:00+11:00", "2024-04-07T01:30:00+10:30", "2024-04-07T02:00:00+10:30"]},
    {"*/30", [], "Australia/Lord_Howe", ~N[2024-04-07 01:15:01], ["2024-04-07T02:00:00+10:30"]}
  ]

  for {cron_expression, on_ambiguity, timezone, start_date, expected_dates} <-
        tests_find_date_tz_changes do
    @cron_expression cron_expression
    @on_ambiguity on_ambiguity
    @timezone timezone
    @start_date start_date
    @expected_dates expected_dates
    test "tz changes test #{@cron_expression} from #{NaiveDateTime.to_iso8601(@start_date)} (#{@timezone}; #{inspect(@on_ambiguity)})" do
      cron_expression = Parser.parse!(@cron_expression, false, @on_ambiguity)
      start_date = DateTime.from_naive!(@start_date, @timezone)

      result =
        cron_expression
        |> Crontab.Scheduler.get_next_run_dates(start_date)
        |> Stream.map(&DateTime.to_iso8601/1)
        |> Enum.take(length(@expected_dates))

      assert @expected_dates == result
    end
  end
end
