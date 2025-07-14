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
      {"DST to STD", "Europe/Zurich", ~N[2025-10-26 01:00:00], ~N[2025-10-27 01:00:00]},
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
      {"America/New_York", ~N[2025-11-02 00:59:01], ~N[2025-11-02 01:00:01], [:earlier]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:29:02], ~N[2025-04-06 01:30:02], [:earlier]},
      {"Europe/Zurich", ~N[2025-10-26 01:59:03], ~N[2025-10-26 02:00:03], [:earlier]},
      {"America/New_York", ~N[2025-11-02 00:59:01], ~N[2025-11-02 01:00:01], [:earlier, :later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:29:02], ~N[2025-04-06 01:30:02], [:earlier, :later]},
      {"Europe/Zurich", ~N[2025-10-26 01:59:03], ~N[2025-10-26 02:00:03], [:earlier, :later]},
    ] do
      test "returns daylight time for #{timezone} when opts = #{inspect opts}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected} <- [
      {"America/New_York", ~N[2025-11-02 00:59:04], ~N[2025-11-02 01:00:04]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:29:05], ~N[2025-04-06 01:30:05]},
      {"Europe/Zurich", ~N[2025-10-26 01:59:06], ~N[2025-10-26 02:00:06]},
    ] do
      test "returns standard time for #{timezone} when opts = [:later]" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, _, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, [:later]) == expected
      end
    end
  end

  describe "shift/4 by minute when in ambiguous daylight time" do
    for {timezone, given, expected} <- [
      {"America/New_York", ~N[2025-11-02 00:59:10], ~N[2025-11-02 01:00:10]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:29:11], ~N[2025-04-06 01:30:11]},
      {"Europe/Zurich", ~N[2025-10-26 01:59:12], ~N[2025-10-26 02:00:12]},
    ] do
      test "returns standard when ambiguous to ambiguous [:earlier, :later] #{timezone}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, [:earlier, :later]) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
      {"America/New_York", ~N[2025-11-02 01:58:13], ~N[2025-11-02 01:59:13], [:earlier]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:58:14], ~N[2025-04-06 01:59:14], [:earlier]},
      {"Europe/Zurich", ~N[2025-10-26 02:58:15], ~N[2025-10-26 02:59:15], [:earlier]},
      {"America/New_York", ~N[2025-11-02 01:58:13], ~N[2025-11-02 01:59:13], [:earlier, :later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:58:14], ~N[2025-04-06 01:59:14], [:earlier, :later]},
      {"Europe/Zurich", ~N[2025-10-26 02:58:15], ~N[2025-10-26 02:59:15], [:earlier, :later]},
    ] do
      test "returns daylight when shift stays in daylight #{inspect opts} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, given, _} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, expected, _} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
      {"America/New_York", ~N[2025-11-02 01:58:13], ~N[2025-11-02 01:59:13], [:later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:58:14], ~N[2025-04-06 01:59:14], [:later]},
      {"Europe/Zurich", ~N[2025-10-26 02:58:15], ~N[2025-10-26 02:59:15], [:later]},
      {"America/New_York", ~N[2025-11-02 01:58:13], ~N[2025-11-02 01:59:13], [:earlier, :later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:58:14], ~N[2025-04-06 01:59:14], [:earlier, :later]},
      {"Europe/Zurich", ~N[2025-10-26 02:58:15], ~N[2025-10-26 02:59:15], [:earlier, :later]},
    ] do
      test "returns standard when shift stays in standard #{inspect opts} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, _, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ambiguous, _, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end

    for {timezone, given, expected, opts} <- [
      {"America/New_York", ~N[2025-11-02 01:59:16], ~N[2025-11-02 02:00:16], [:later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:59:17], ~N[2025-04-06 02:00:17], [:later]},
      {"Europe/Zurich", ~N[2025-10-26 02:59:18], ~N[2025-10-26 03:00:18], [:later]},
      {"America/New_York", ~N[2025-11-02 01:59:16], ~N[2025-11-02 02:00:16], [:earlier, :later]},
      {"Australia/Lord_Howe", ~N[2025-04-06 01:59:17], ~N[2025-04-06 02:00:17], [:earlier, :later]},
      {"Europe/Zurich", ~N[2025-10-26 02:59:18], ~N[2025-10-26 03:00:18], [:earlier, :later]},
    ] do
      test "returns standard when shift to non-ambiguous standard #{inspect opts} #{timezone}" do
        timezone = unquote(timezone)
        {:ambiguous, _, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ok, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)
        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end
  end

  for opts <- [[:earlier], [:later], [:earlier, :later]] do
    for {timezone, given, expected} <- [
      {"America/New_York", ~N[2025-03-09 01:59:00], ~N[2025-03-09 03:00:00]},
      {"Australia/Lord_Howe", ~N[2025-10-05 01:59:00], ~N[2025-10-05 02:30:00]},
      {"Europe/Zurich", ~N[2025-03-30 01:59:00], ~N[2025-03-30 03:00:00], [:earlier]},
    ] do
      test "shift/4 by minute from standard to daylight for #{timezone} with #{inspect opts}" do
        timezone = unquote(timezone)
        {:ok, given} = DateTime.from_naive(unquote(Macro.escape(given)), timezone)
        {:ok, expected} = DateTime.from_naive(unquote(Macro.escape(expected)), timezone)

        assert DateHelper.shift(given, 1, :minute, unquote(Macro.escape(opts))) == expected
      end
    end
  end
end
