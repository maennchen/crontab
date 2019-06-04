defmodule Crontab.CronExpression.ParserTest do
  use ExUnit.Case, async: true
  doctest Crontab.CronExpression.Parser
  import Crontab.CronExpression.Parser
  import Crontab.CronExpression

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
    assert parse("*/4,9,JAN-DEC") == {:error, "Can't parse JAN as minute."}
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

  test "parse minute followed by string gives error" do
    assert parse("42invalid * * * *") == {:error, "Can't parse 42invalid as minute."}
  end

  test "parse negative minute gives error" do
    assert parse("-1 * * * *") == {:error, "Can't parse -1 as minute."}
  end

  test "parse out of range minute gives error" do
    assert parse("60 * * * *") == {:error, "Can't parse 60 as minute."}
  end

  test "parse negative hour gives error" do
    assert parse("* -1 * * *") == {:error, "Can't parse -1 as hour."}
  end

  test "parse out of range hour gives error" do
    assert parse("* 24 * * *") == {:error, "Can't parse 24 as hour."}
  end

  test "parse day of month below allowed range gives error" do
    assert parse("* * 0 * *") == {:error, "Can't parse 0 as day of month."}
  end

  test "parse day of month with trailing string gives error" do
    assert parse("* * 1invalid * *") == {:error, "Can't parse 1invalid as day of month."}
  end

  test "parse day of month above allowed range gives error" do
    assert parse("* * 32 * *") == {:error, "Can't parse 32 as day of month."}
  end

  test "parse weekday nearest day of month below allowed range gives error" do
    assert parse("* * 0W * *") == {:error, "Can't parse 0 as day of month."}
  end

  test "parse weekday nearest day of month above allowed range gives error" do
    assert parse("* * 32W * *") == {:error, "Can't parse 32 as day of month."}
  end

  test "parse invalid month gives error" do
    assert parse("* * * invalid *") == {:error, "Can't parse invalid as month."}
  end

  test "parse month with trailing string gives error" do
    assert parse("* * * 2invalid *") == {:error, "Can't parse 2invalid as month."}
  end

  test "parse month below allowed range gives error" do
    assert parse("* * * 0 *") == {:error, "Can't parse 0 as month."}
  end

  test "parse month above allowed range gives error" do
    assert parse("* * * 13 *") == {:error, "Can't parse 13 as month."}
  end

  test "parse day of week below allowed range gives error" do
    assert parse("* * * * -1") == {:error, "Can't parse -1 as day of week."}
  end

  test "parse day of week above allowed range gives error" do
    assert parse("* * * * 8") == {:error, "Can't parse 8 as day of week."}
  end

  test "parse invalid day of week gives error" do
    assert parse("* * * * invalid") == {:error, "Can't parse invalid as day of week."}
  end

  test "parse invalid last day of week gives error" do
    assert parse("* * * * invalidL") == {:error, "Can't parse invalid as day of week."}
  end

  test "parse last day of week below allowed range gives error" do
    assert parse("* * * * -1L") == {:error, "Can't parse -1 as day of week."}
  end

  test "parse last day of week above allowed range gives error" do
    assert parse("* * * * 8L") == {:error, "Can't parse 8 as day of week."}
  end

  test "parse invalid second day of week in a month gives error" do
    assert parse("* * * * invalid#2") == {:error, "Can't parse invalid as day of week."}
  end

  test "parse second day of week in a month below allowed range gives error" do
    assert parse("* * * * -1#2") == {:error, "Can't parse -1 as day of week."}
  end

  test "parse second day of week in a month above allowed range gives error" do
    assert parse("* * * * 8#2") == {:error, "Can't parse 8 as day of week."}
  end

  test "parse day of week followed by string gives error" do
    assert parse("* * * * 5invalid") == {:error, "Can't parse 5invalid as day of week."}
  end

  test "parse invalid range increment" do
    assert parse("* 4/8 * * *") == {:error, "Can't parse 4 as a range."}
  end

  test "parse valid range increment" do
    assert parse("* 0-12/2 * * *") == {:ok, ~e[* 0-12/2 * * * *]}
  end

  test "parse invalid month range start gives error" do
    assert parse("* * * 0-10 *") == {:error, "Can't parse 0 as month."}
  end

  test "parse invalid month range end gives error" do
    assert parse("* * * 1-13 *") == {:error, "Can't parse 13 as month."}
  end

  test "parse valid star range increment" do
    assert parse("* */8 * * *") == {:ok, ~e[* */8 * * * *]}
  end

  test "parse invalid range increment gives error" do
    assert parse("* 1-10/2invalid * * *") == {:error, "Can't parse 2invalid as increment."}
  end

  test "parse invalid star increment gives error" do
    assert parse("* */8invalid * * *") == {:error, "Can't parse 8invalid as increment."}
  end

  test "parse valid list" do
    assert parse("* 2,4,6 * * *") == {:ok, ~e[* 2,4,6 * * * *]}
  end

  test "parse out of range list element gives error" do
    assert parse("* 2,4,24 * * *") == {:error, "Can't parse 24 as hour."}
  end

  test "parse invalid list element gives error" do
    assert parse("* 2,4,invalid * * *") == {:error, "Can't parse invalid as hour."}
  end
end
