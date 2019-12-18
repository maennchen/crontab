defmodule Crontab.CronExpression.ParserTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Crontab.CronExpression.Parser

  import Crontab.CronExpression.Parser
  import Crontab.CronExpression

  test ~s(parse "@reboot" gives reboot") do
    assert parse("@reboot") ==
             {:ok,
              %Crontab.CronExpression{
                reboot: true,
                extended: false,
                minute: [:*],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "@REBOOT" gives reboot) do
    assert parse("@REBOOT") ==
             {:ok,
              %Crontab.CronExpression{
                reboot: true,
                extended: false,
                minute: [:*],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test "parse \"@unknown\" gives error" do
    assert {:error, _} = parse("@unknown")
  end

  test ~s("parse "@yearly" gives yearly) do
    assert parse("@yearly") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [1],
                month: [1],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s("parse "@annually" gives yearly) do
    assert parse("@annually") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [1],
                month: [1],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s("parse "@monthly" gives monthly) do
    assert parse("@monthly") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [1],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "@weekly" gives weekly) do
    assert parse("@weekly") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [:*],
                month: [:*],
                weekday: [0],
                year: [:*]
              }}
  end

  test ~s(parse "@daily" gives daily) do
    assert parse("@daily") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "@midnight" gives daily) do
    assert parse("@midnight") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [0],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "@hourly" gives hourly) do
    assert parse("@hourly") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [0],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "@minutely" gives hourly) do
    assert parse("@minutely") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [:*],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s("parse "@secondly" gives hourly) do
    assert parse("@secondly") ==
             {:ok,
              %Crontab.CronExpression{
                extended: true,
                second: [:*],
                minute: [:*],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test "parse \"1 2 3 4 5 6 7\" gives error" do
    assert {:error, _} = parse("1 2 3 4 5 6 7")
  end

  test ~s(parse "*" gives minutely) do
    assert parse("*") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [:*],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "*/4,9,1-10" gives [{:"/", :*, 4}, 9, {:"-", 1, 10}]) do
    assert parse("*/4,9,1-10") ==
             {:ok,
              %Crontab.CronExpression{
                minute: [{:/, :*, 4}, 9, {:-, 1, 10}],
                hour: [:*],
                day: [:*],
                month: [:*],
                weekday: [:*],
                year: [:*]
              }}
  end

  test "parse \"*/4,9,JAN-DEC\" gives error" do
    assert {:error, _} = parse("*/4,9,JAN-DEC")
  end

  test ~s(parse "* * * JAN-DEC" gives [{:-, 1, 12}]) do
    assert parse("* * * JAN-DEC") ==
             {:ok,
              %Crontab.CronExpression{
                day: [:*],
                hour: [:*],
                minute: [:*],
                month: [{:-, 1, 12}],
                weekday: [:*],
                year: [:*]
              }}
  end

  test ~s(parse "* * * MON-TUE" gives [{:-, 1, 2}]) do
    assert parse("* * * * MON-TUE") ==
             {:ok,
              %Crontab.CronExpression{
                day: [:*],
                hour: [:*],
                minute: [:*],
                month: [:*],
                weekday: [{:-, 1, 2}],
                year: [:*]
              }}
  end

  test "parse second followed by string gives error" do
    assert parse("42invalid * * * *", true) == {:error, "Can't parse 42invalid as second."}
  end

  test "parse negative second gives error" do
    assert parse("-1", true) == {:error, "Can't parse -1 as second."}
  end

  test "parse out of range second gives error" do
    assert parse("60", true) == {:error, "Can't parse 60 as second."}
  end

  test "valid seconds do not give error" do
    assert parse("10", true) == {:ok, ~e[10 * * * * * *]e}
    assert parse("*/10", true) == {:ok, ~e[*/10 * * * * * *]e}
  end

  test "parse minute followed by string gives error" do
    assert {:error,
            %Crontab.CronExpression.Parser.ParseError{
              column: 2,
              message:
                "expected special or minute_expression, followed by space, followed by hour_expression, followed by space, followed by day_expression, followed by space, followed by month_expression, followed by space, followed by weekday_expression, followed by space, followed by year_expression, followed by end of string or end of string, followed by end of string or end of string, followed by end of string or end of string, followed by end of string or end of string, followed by end of string or end of string",
              rest: "invalid * * * *"
            }} = parse("42invalid * * * *")
  end

  test "parse negative minute gives error" do
    assert {:error,
            %Crontab.CronExpression.Parser.ParseError{
              column: 2,
              message: "number -1 must be between 0 and 59",
              rest: " * * * *"
            }} = parse("-1 * * * *")
  end

  test "parse out of range minute gives error" do
    assert {:error,
            %Crontab.CronExpression.Parser.ParseError{
              column: 2,
              message: "number 60 must be between 0 and 59",
              rest: " * * * *"
            }} = parse("60 * * * *")
  end

  test "parse negative hour gives error" do
    assert {:error, _} = parse("* -1 * * *")
  end

  test "parse out of range hour gives error" do
    assert {:error, _} = parse("* 24 * * *")
  end

  test "parse day of month below allowed range gives error" do
    assert {:error, _} = parse("* * 0 * *")
  end

  test "parse day of month with trailing string gives error" do
    assert {:error, _} = parse("* * 1invalid * *")
  end

  test "parse day of month above allowed range gives error" do
    assert {:error, _} = parse("* * 32 * *")
  end

  test "parse weekday nearest day of month below allowed range gives error" do
    assert {:error, _} = parse("* * 0W * *")
  end

  test "parse weekday nearest day of month above allowed range gives error" do
    assert {:error, _} = parse("* * 32W * *")
  end

  test "parse invalid month gives error" do
    assert {:error, _} = parse("* * * invalid *")
  end

  test "parse month with trailing string gives error" do
    assert {:error, _} = parse("* * * 2invalid *")
  end

  test "parse month below allowed range gives error" do
    assert {:error, _} = parse("* * * 0 *")
  end

  test "parse month above allowed range gives error" do
    assert {:error, _} = parse("* * * 13 *")
  end

  test "parse day of week below allowed range gives error" do
    assert {:error, _} = parse("* * * * -1")
  end

  test "parse day of week above allowed range gives error" do
    assert {:error, _} = parse("* * * * 8")
  end

  test "parse invalid day of week gives error" do
    assert {:error, _} = parse("* * * * invalid")
  end

  test "parse invalid last day of week gives error" do
    assert {:error, _} = parse("* * * * invalidL")
  end

  test "parse last day of week below allowed range gives error" do
    assert {:error, _} = parse("* * * * -1L")
  end

  test "parse last day of week above allowed range gives error" do
    assert {:error, _} = parse("* * * * 8L")
  end

  test "parse invalid second day of week in a month gives error" do
    assert {:error, _} = parse("* * * * invalid#2")
  end

  test "parse second day of week in a month below allowed range gives error" do
    assert {:error, _} = parse("* * * * -1#2")
  end

  test "parse second day of week in a month above allowed range gives error" do
    assert {:error, _} = parse("* * * * 8#2")
  end

  test "parse day of week followed by string gives error" do
    assert {:error, _} = parse("* * * * 5invalid")
  end

  test "parse invalid range increment" do
    assert {:error, _} = parse("* 4/8 * * *")
  end

  test "parse valid range increment" do
    assert parse("* 0-12/2 * * *") == {:ok, ~e[* 0-12/2 * * * *]}
  end

  test "parse invalid month range start gives error" do
    assert {:error, _} = parse("* * * 0-10 *")
  end

  test "parse invalid month range end gives error" do
    assert {:error, _} = parse("* * * 1-13 *")
  end

  test "parse valid star range increment" do
    assert parse("* */8 * * *") == {:ok, ~e[* */8 * * * *]}
  end

  test "parse invalid range increment gives error" do
    assert {:error, _} = parse("* 1-10/2invalid * * *")
  end

  test "parse invalid star increment gives error" do
    assert {:error, _} = parse("* */8invalid * * *")
  end

  test "parse valid list" do
    assert parse("* 2,4,6 * * *") == {:ok, ~e[* 2,4,6 * * * *]}
  end

  test "parse out of range list element gives error" do
    assert {:error, _} = parse("* 2,4,24 * * *")
  end

  test "parse invalid list element gives error" do
    assert {:error, _} = parse("* 2,4,invalid * * *")
  end

  test "parse zero divider gives error" do
    assert {:error, _} = parse("*/0")
  end

  describe "parse/2 non-range step value" do
    setup do: %{now: ~N[2024-01-01 00:00:01]}

    test "for second", %{now: now} do
      {:ok, expr} = parse("0/2 * * * * * *", true)
      expected = [~N[2024-01-01 00:00:02], ~N[2024-01-01 00:00:04]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for minute", %{now: now} do
      {:ok, expr} = parse("0/2 * * * * *")
      expected = [~N[2024-01-01 00:02:00], ~N[2024-01-01 00:04:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for hour", %{now: now} do
      {:ok, expr} = parse("0 0/2 * * * *")
      expected = [~N[2024-01-01 02:00:00], ~N[2024-01-01 04:00:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for day", %{now: now} do
      {:ok, expr} = parse("0 0 1/2 * * *")
      expected = [~N[2024-01-03 00:00:00], ~N[2024-01-05 00:00:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for month", %{now: now} do
      {:ok, expr} = parse("0 0 1 1/2 * *")
      expected = [~N[2024-03-01 00:00:00], ~N[2024-05-01 00:00:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for weekday", %{now: now} do
      {:ok, expr} = parse("0 0 * * 2/2 *")
      expected = [~N[2024-01-02 00:00:00], ~N[2024-01-04 00:00:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "for year", %{now: now} do
      {:ok, expr} = parse("0 0 1 1 * 2024/2")
      expected = [~N[2026-01-01 00:00:00], ~N[2028-01-01 00:00:00]]

      assert expr |> Crontab.Scheduler.get_next_run_dates(now) |> Enum.take(2) == expected
    end

    test "parse non-range step value gives error when given a negative integer" do
      assert parse("-8/2 * * * *") == {:error, "Can't parse -8 as minute."}
    end
  end
end
