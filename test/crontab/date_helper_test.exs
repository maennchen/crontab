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

  describe "shift/4 on DateTime NYT from daylight savings to standard time" do
    @tz "America/New_York"
    @date ~D[2024-11-03]

    for {from_time, unit, to_time} <- [
          {~T[01:59:58], :second, ~T[01:59:59]},
          {~T[01:58:59], :minute, ~T[01:59:59]}
        ] do
      test "add one #{unit} to #{from_time}am EDT returns #{to_time}am EDT" do
        {:ambiguous, from, _} = DateTime.new(@date, unquote(Macro.escape(from_time)), @tz)
        {:ambiguous, expected, _} = DateTime.new(@date, unquote(Macro.escape(to_time)), @tz)

        assert DateHelper.shift(from, 1, unquote(unit), [:later]) == expected
      end
    end

    for {from_time, unit, to_time} <- [
          {~T[01:59:59], :second, ~T[01:00:00]},
          {~T[01:59:00], :minute, ~T[01:00:00]}
        ] do
      test "add 1 #{unit} to #{from_time}am EDT returns #{to_time}am EST" do
        {:ambiguous, from, _} = DateTime.new(@date, unquote(Macro.escape(from_time)), @tz)
        {:ambiguous, _, expected} = DateTime.new(@date, unquote(Macro.escape(to_time)), @tz)

        assert DateHelper.shift(from, 1, unquote(unit), [:later]) == expected
      end
    end

    for ambiguity_opts <- [[:earlier], [:earlier, :later]] do
      test "add 1 hour to 12am EDT returns 1am EDT when ambiguity_opt=#{inspect(ambiguity_opts)}" do
        from = DateTime.new!(@date, ~T[00:00:00], @tz)
        {:ambiguous, expected, _} = DateTime.new(@date, ~T[01:00:00], @tz)
        opts = unquote(Macro.escape(ambiguity_opts))

        assert DateHelper.shift(from, 1, :hour, opts) == expected
      end
    end

    test "add 1 hour to 12am EDT returns 1am EST when ambiguity_opt=[:later]" do
      from = DateTime.new!(@date, ~T[00:00:00], @tz)
      {:ambiguous, _, expected} = DateTime.new(@date, ~T[01:00:00], @tz)

      assert DateHelper.shift(from, 1, :hour, [:later]) == expected
    end

    test "add 1 hour to 1am EDT returns 1am EST when ambiguity_opt=[:earlier, :later]" do
      {:ambiguous, from_time, expected} = DateTime.new(@date, ~T[01:00:00], @tz)

      assert DateHelper.shift(from_time, 1, :hour, [:earlier, :later]) == expected
    end
  end

  test "add one second to 2 seconds before EST ends" do
    from = DateTime.new!(~D[2024-03-10], ~T[01:59:58], "America/New_York")
    expected = DateTime.new!(~D[2024-03-10], ~T[01:59:59], "America/New_York")

    assert DateHelper.shift(from, 1, :second) == expected
  end

  describe "shift/4 on DateTime NYT from standard to daylight savings" do
    @tz "America/New_York"
    @date ~D[2024-03-10]

    for {unit, expected} <- [
          {:second, DateTime.new!(@date, ~T[03:00:00], @tz)},
          {:minute, DateTime.new!(@date, ~T[03:00:59], @tz)},
          {:hour, DateTime.new!(@date, ~T[03:59:59], @tz)},
          # ensure hour stays at 1:59:59am
          {:day, DateTime.new!(Date.add(@date, 1), ~T[01:59:59], @tz)}
        ] do
      test "add 1 #{unit} to 1 second before EST ends returns #{inspect(expected)}" do
        from = DateTime.new!(@date, ~T[01:59:59], @tz)

        assert DateHelper.shift(from, 1, unquote(unit)) == unquote(Macro.escape(expected))
      end
    end
  end

  describe "shift/4 on DateTime NYT from daylight savings back to standard time" do
    @tz "America/New_York"
    @date ~D[2024-03-10]

    for {unit, expected} <- [
          {:second, DateTime.new!(@date, ~T[01:59:59], @tz)},
          {:minute, DateTime.new!(@date, ~T[01:59:00], @tz)},
          {:hour, DateTime.new!(@date, ~T[01:00:00], @tz)},
          # ensure hour stays at 3am
          {:day, DateTime.new!(Date.add(@date, -1), ~T[03:00:00], @tz)}
        ] do
      test "subtract 1 #{unit} from 3am when EST has already ended returns #{inspect(expected)}" do
        from = DateTime.new!(@date, ~T[03:00:00], @tz)

        assert DateHelper.shift(from, -1, unquote(unit)) == unquote(Macro.escape(expected))
      end
    end
  end

  describe "shift/4 on DateTime NYT from standard back to daylight savings" do
    @tz "America/New_York"
    @date ~D[2024-11-03]

    for {unit, to_time, ambiguity_opts} <- [
          {:second, ~T[01:59:59], [:later]},
          {:minute, ~T[01:59:00], [:later]},
          {:hour, ~T[01:00:00], [:later]},
          {:second, ~T[01:59:59], [:earlier, :later]},
          {:minute, ~T[01:59:00], [:earlier, :later]},
          {:hour, ~T[01:00:00], [:earlier, :later]}
        ] do
      test "subtract 1 #{unit} from EST 1am returns #{inspect(to_time)}am EDT when ambiguity_opts = #{inspect(ambiguity_opts)}" do
        {:ambiguous, _, from} = DateTime.new(@date, ~T[01:00:00], @tz)
        {:ambiguous, expected, _} = DateTime.new(@date, unquote(Macro.escape(to_time)), @tz)
        opts = unquote(Macro.escape(ambiguity_opts))

        assert DateHelper.shift(from, -1, unquote(unit), opts) == expected
      end
    end

    test "subtract 1 hour from EST 2am returns 1am EDT when ambiguity_opts = [:earlier]" do
      from = DateTime.new!(@date, ~T[02:00:00], @tz)
      {:ambiguous, expected, _} = DateTime.new(@date, ~T[01:00:00], @tz)

      assert DateHelper.shift(from, -1, :hour, [:earlier]) == expected
    end

    for opts <- [[:later], [:earlier], [:earlier, :later]] do
      test "subtract 1 day from EST 1am returns 1am EDT of one day earlier when ambiguity_opts = #{inspect(opts)}" do
        {:ambiguous, _, from} = DateTime.new(@date, ~T[01:00:00], @tz)
        expected = DateTime.new!(Date.add(@date, -1), ~T[01:00:00], @tz)

        assert DateHelper.shift(from, -1, :day, unquote(Macro.escape(opts))) == expected
      end
    end
  end
end
