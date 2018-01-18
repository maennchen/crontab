defmodule Crontab.CronExpression.ParserTest do
  use ExUnit.Case, async: true
  doctest Crontab.CronExpression.Parser
  import Crontab.CronExpression.Parser

  test "parse \"@reboot\" gives reboot" do
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

  test "parse \"@REBOOT\" gives reboot" do
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
    assert parse("@unknown") == {:error, "Special identifier @unknown is undefined."}
  end

  test "parse \"@yearly\" gives yearly" do
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

  test "parse \"@annually\" gives yearly" do
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

  test "parse \"@monthly\" gives monthly" do
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

  test "parse \"@weekly\" gives weekly" do
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

  test "parse \"@daily\" gives daily" do
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

  test "parse \"@midnight\" gives daily" do
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

  test "parse \"@hourly\" gives hourly" do
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

  test "parse \"@minutely\" gives hourly" do
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

  test "parse \"@secondly\" gives hourly" do
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
    assert parse("1 2 3 4 5 6 7") == {:error, "The Cron Format String contains to many parts."}
  end

  test "parse \"*\" gives minutely" do
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

  test "parse \"*/4,9,1-10\" gives [{:\"/\", :*, 4}, 9, {:\"-\", 1, 10}]" do
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
    assert parse("*/4,9,JAN-DEC") == {:error, "Can't parse JAN as interval minute."}
  end

  test "parse \"* * * JAN-DEC\" gives [{:-, 1, 12}]" do
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

  test "parse \"* * * MON-TUE\" gives [{:-, 1, 2}]" do
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
end
