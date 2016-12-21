defmodule Crontab.CronFormatParserTest do
  use ExUnit.Case
  doctest Crontab.CronFormatParser
  import Crontab.CronFormatParser

  test "parse \"@reboot\" gives error" do
    assert parse("@reboot") == {:error, "Special identifier @reboot is not supported."}
  end

  test "parse \"@unknown\" gives error" do
    assert parse("@unknown") == {:error, "Special identifier @unknown is undefined."}
  end

  test "parse \"@yearly\" gives yearly" do
    assert parse("@yearly") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [1], month: [1], weekday: [:*], year: [:*]}}
  end

  test "parse \"@annually\" gives yearly" do
    assert parse("@annually") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [1], month: [1], weekday: [:*], year: [:*]}}
  end

  test "parse \"@monthly\" gives monthly" do
    assert parse("@monthly") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [1], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"@weekly\" gives weekly" do
    assert parse("@weekly") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [:*], month: [:*], weekday: [0], year: [:*]}}
  end

  test "parse \"@daily\" gives daily" do
    assert parse("@daily") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [:*], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"@midnight\" gives daily" do
    assert parse("@midnight") == {:ok, %Crontab.CronInterval{minute: [0], hour: [0], day: [:*], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"@hourly\" gives hourly" do
    assert parse("@hourly") == {:ok, %Crontab.CronInterval{minute: [0], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"1 2 3 4 5 6 7\" gives error" do
    assert parse("1 2 3 4 5 6 7") == {:error, "The Cron Format String contains to many parts."}
  end

  test "parse \"*\" gives minutely" do
    assert parse("*") == {:ok, %Crontab.CronInterval{minute: [:*], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"*/4,9,1-10\" gives [{:\"/\", 4}, 9, {:\"-\", 1, 10}]" do
    assert parse("*/4,9,1-10") == {:ok, %Crontab.CronInterval{minute: [{:"/", 4}, 9, {:-, 1, 10}], hour: [:*], day: [:*], month: [:*], weekday: [:*], year: [:*]}}
  end

  test "parse \"*/4,9,JAN-DEC\" gives error" do
    assert parse("*/4,9,JAN-DEC") == {:error, "Can't parse JAN as interval minute."}
  end

  test "parse \"* * * JAN-DEC\" gives [{:-, 1, 12}]" do
    assert parse("* * * JAN-DEC") == {:ok, %Crontab.CronInterval{day: [:*], hour: [:*], minute: [:*], month: [{:-, 1, 12}], weekday: [:*], year: [:*]}}
  end

  test "parse \"* * * MON-TUE\" gives [{:-, 1, 2}]" do
    assert parse("* * * * MON-TUE") == {:ok, %Crontab.CronInterval{day: [:*], hour: [:*], minute: [:*], month: [:*], weekday: [{:-, 1, 2}], year: [:*]}}
  end
end
