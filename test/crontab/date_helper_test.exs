defmodule Crontab.DateHelperTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Crontab.DateHelper
  alias Crontab.DateHelper

  describe "nth_weekday/3" do
    refute DateHelper.nth_weekday(~N[2024-11-01 00:00:00], 1, 5)
    assert DateHelper.nth_weekday(~N[2024-12-01 00:00:00], 1, 5) == 30
    assert DateHelper.nth_weekday(~N[2024-09-01 00:00:00], 1, 5) == 30
  end

  describe "inc_month/1" do
    test "does not jump over month" do
      assert DateHelper.inc_month(~N[2019-05-31 23:00:00]) == ~N[2019-06-01 23:00:00]
    end
  end

  describe "dec_year/1" do
    test "non-leap year back to leap year at end feb" do
      given = ~N[2025-02-28 00:00:00]
      assert DateHelper.dec_year(given) == ~N[2024-02-28 00:00:00]
    end

    test "leap year back to non-leap year at end feb" do
      given = ~N[2024-02-29 00:00:00]
      assert DateHelper.dec_year(given) == ~N[2023-02-28 00:00:00]
    end

    test "non-leap year back to leap year at start mar" do
      given = ~N[2025-03-01 00:00:00]
      assert DateHelper.dec_year(given) == ~N[2024-03-01 00:00:00]
    end

    test "leap year back to non-leap year at start mar" do
      given = ~N[2024-03-01 00:00:00]
      assert DateHelper.dec_year(given) == ~N[2023-03-01 00:00:00]
    end

    test "non-leap year back to non-leap year" do
      given = ~N[2026-03-01 00:00:00]
      assert DateHelper.dec_year(given) == ~N[2025-03-01 00:00:00]
    end
  end

  describe "inc_year/1" do
    test "non-leap year to leap year at end feb" do
      given = ~N[2023-02-28 00:00:00]
      assert DateHelper.inc_year(given) == ~N[2024-02-28 00:00:00]
    end

    test "leap year to non-leap year at end feb" do
      given = ~N[2024-02-29 00:00:00]
      assert DateHelper.inc_year(given) == ~N[2025-02-28 00:00:00]
    end

    test "non-leap year to leap year at start mar" do
      given = ~N[2023-03-01 00:00:00]
      assert DateHelper.inc_year(given) == ~N[2024-03-01 00:00:00]
    end

    test "leap year to non-leap year at start mar" do
      given = ~N[2024-03-01 00:00:00]
      assert DateHelper.inc_year(given) == ~N[2025-03-01 00:00:00]
    end

    test "non-leap year to non-leap year" do
      given = ~N[2025-03-01 00:00:00]
      assert DateHelper.inc_year(given) == ~N[2026-03-01 00:00:00]
    end
  end

  describe "shift/4 on NaiveDateTime" do
    test "one day to day before NY DST starts" do
      date = ~N[2024-03-09 12:34:56]
      assert DateHelper.shift(date, 1, :day) == ~N[2024-03-10 12:34:56]
    end
  end

  describe "shift/4 on DateTime UTC" do
    test "one day to day before NY DST starts" do
      date = ~U[2024-03-09 12:34:56Z]
      assert DateHelper.shift(date, 1, :day) == ~U[2024-03-10 12:34:56Z]
    end
  end

  describe "shift/4 by day keeps to same hour" do
    tests = [
      {"STD to STD", "America/New_York", ~N[2025-07-18 12:34:56], ~N[2025-07-19 12:34:56]},
      {"STD to DST", "America/New_York", ~N[2025-03-09 01:00:00], ~N[2025-03-10 01:00:00]},
      {"DST to STD", "America/New_York", ~N[2025-11-02 00:30:00], ~N[2025-11-03 00:30:00]},
      {"STD to DST", "Australia/Lord_Howe", ~N[2025-10-05 01:00:00], ~N[2025-10-06 01:00:00]},
      {"DST to STD", "Australia/Lord_Howe", ~N[2025-04-06 01:00:00], ~N[2025-04-07 01:00:00]},
      {"STD to DST", "Europe/Zurich", ~N[2025-03-30 01:00:00], ~N[2025-03-31 01:00:00]},
      {"DST to STD", "Europe/Zurich", ~N[2025-10-26 01:00:00], ~N[2025-10-27 01:00:00]}
    ]

    for {desc, timezone, given, expected} <- tests do
      test "#{desc} #{timezone}" do
        timezone = unquote(timezone)
        dt = DateTime.from_naive!(unquote(Macro.escape(given)), timezone)
        expected = DateTime.from_naive!(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(dt, 1, :day) == expected
      end
    end
  end

  describe "shift/4 by minute from non-ambiguous daylight time ambiguous daylight/standard time" do
    for {timezone, given, expected, opts} <- [
          {"America/New_York", ~N[2025-11-02 00:59:01], ~N[2025-11-02 01:00:01], [:prior]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:29:02], ~N[2025-04-06 01:30:02], [:prior]},
          {"Europe/Zurich", ~N[2025-10-26 01:59:03], ~N[2025-10-26 02:00:03], [:prior]},
          {"America/New_York", ~N[2025-11-02 00:59:01], ~N[2025-11-02 01:00:01],
           [:prior, :subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:29:02], ~N[2025-04-06 01:30:02],
           [:prior, :subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 01:59:03], ~N[2025-10-26 02:00:03],
           [:prior, :subsequent]}
        ] do
      test "returns daylight time for #{timezone} when opts = #{inspect(opts)}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected} <- [
          {"America/New_York", ~N[2025-11-02 00:59:04], ~N[2025-11-02 01:00:04]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:29:05], ~N[2025-04-06 01:30:05]},
          {"Europe/Zurich", ~N[2025-10-26 01:59:06], ~N[2025-10-26 02:00:06]}
        ] do
      test "returns standard time for #{timezone} when opts = [:subsequent]" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, _, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, [:subsequent]) == expected
      end
    end
  end

  describe "shift/4 by minute when in ambiguous daylight time" do
    for {timezone, given, expected} <- [
          {"America/New_York", ~N[2025-11-02 00:59:10], ~N[2025-11-02 01:00:10]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:29:11], ~N[2025-04-06 01:30:11]},
          {"Europe/Zurich", ~N[2025-10-26 01:59:12], ~N[2025-10-26 02:00:12]}
        ] do
      test "returns standard when ambiguous to ambiguous [:prior, :subsequent] #{timezone}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, [:prior, :subsequent]) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
          {"America/New_York", ~N[2025-11-02 01:58:13], ~N[2025-11-02 01:59:13], [:prior]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:58:14], ~N[2025-04-06 01:59:14], [:prior]},
          {"Europe/Zurich", ~N[2025-10-26 02:58:15], ~N[2025-10-26 02:59:15], [:prior]},
          {"America/New_York", ~N[2025-11-02 01:58:16], ~N[2025-11-02 01:59:16],
           [:prior, :subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:58:17], ~N[2025-04-06 01:59:17],
           [:prior, :subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 02:58:18], ~N[2025-10-26 02:59:18],
           [:prior, :subsequent]}
        ] do
      test "returns daylight when shift stays in daylight #{inspect(opts)} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, given, _} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
          {"America/New_York", ~N[2025-11-02 01:58:19], ~N[2025-11-02 01:59:19], [:subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:58:20], ~N[2025-04-06 01:59:20],
           [:subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 02:58:21], ~N[2025-10-26 02:59:21], [:subsequent]},
          {"America/New_York", ~N[2025-11-02 01:58:22], ~N[2025-11-02 01:59:22],
           [:prior, :subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:58:23], ~N[2025-04-06 01:59:23],
           [:prior, :subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 02:58:24], ~N[2025-10-26 02:59:24],
           [:prior, :subsequent]}
        ] do
      test "returns standard when shift stays in standard #{inspect(opts)} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, _, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, _, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
          {"America/New_York", ~N[2025-11-02 01:59:25], ~N[2025-11-02 02:00:25], [:subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:59:26], ~N[2025-04-06 02:00:26],
           [:subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 02:59:27], ~N[2025-10-26 03:00:27], [:subsequent]},
          {"America/New_York", ~N[2025-11-02 01:59:28], ~N[2025-11-02 02:00:28],
           [:prior, :subsequent]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:59:29], ~N[2025-04-06 02:00:29],
           [:prior, :subsequent]},
          {"Europe/Zurich", ~N[2025-10-26 02:59:30], ~N[2025-10-26 03:00:30],
           [:prior, :subsequent]}
        ] do
      test "returns standard when shift to non-ambiguous standard #{inspect(opts)} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, _, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ok, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected} <- [
          {"America/New_York", ~N[2025-11-02 01:59:31], ~N[2025-11-02 02:00:31]},
          {"Europe/Zurich", ~N[2025-10-26 02:59:32], ~N[2025-10-26 03:00:32]},
          {"Australia/Lord_Howe", ~N[2025-04-06 01:59:33], ~N[2025-04-06 02:00:33]}
        ] do
      test "returns standard when shift from ambiguous daylight [:prior] #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, given, _} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ok, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)

        assert DateHelper.shift(given, 1, :minute, [:prior]) == expected
      end
    end
  end

  for opts <- [[:prior], [:subsequent], [:prior, :subsequent]] do
    for {timezone, given, expected} <- [
          {"America/New_York", ~N[2025-03-09 01:59:34], ~N[2025-03-09 03:00:34]},
          {"Australia/Lord_Howe", ~N[2025-10-05 01:59:35], ~N[2025-10-05 02:30:35]},
          {"Europe/Zurich", ~N[2025-03-30 01:59:36], ~N[2025-03-30 03:00:36], [:prior]}
        ] do
      test "shift/4 by minute from standard to daylight for #{timezone} with #{inspect(opts)}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ok, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)

        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end
  end
end
