defmodule Crontab.DateCheckerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Crontab.CronExpression
  import Crontab.DateChecker

  doctest Crontab.DateChecker

  test "2002-01-13 23:00:07 matches * * * * *" do
    base_date = ~N[2002-01-13 23:00:07]
    assert matches_date?(:minute, [:*], base_date, []) == true
    assert matches_date?(:hour, [:*], base_date, []) == true
    assert matches_date?(:day, [:*], base_date, []) == true
    assert matches_date?(:month, [:*], base_date, []) == true
    assert matches_date?(:weekday, [:*], base_date, []) == true
    assert matches_date?(:year, [:*], base_date, []) == true
  end

  test "2002-01-13 23:00:07Z matches * * * * *" do
    base_date = ~U[2002-01-13 23:00:07Z]
    assert matches_date?(:minute, [:*], base_date, []) == true
    assert matches_date?(:hour, [:*], base_date, []) == true
    assert matches_date?(:day, [:*], base_date, []) == true
    assert matches_date?(:month, [:*], base_date, []) == true
    assert matches_date?(:weekday, [:*], base_date, []) == true
    assert matches_date?(:year, [:*], base_date, []) == true
  end

  test "2004-04-16 04:04:08 matches */4 */4 */4 */5 */4" do
    base_date = ~N[2004-04-16 04:04:08]
    assert matches_date?(:second, [{:/, :*, 4}], base_date, []) == true
    assert matches_date?(:minute, [{:/, :*, 4}], base_date, []) == true
    assert matches_date?(:hour, [{:/, :*, 4}], base_date, []) == true
    assert matches_date?(:day, [{:/, :*, 4}], base_date, []) == true
    assert matches_date?(:month, [{:/, :*, 4}], base_date, []) == true
    assert matches_date?(:weekday, [{:/, :*, 5}], base_date, []) == true
    assert matches_date?(:year, [{:/, :*, 4}], base_date, []) == true
  end

  test "2003-04-17 04:04:08 doesn't match */3 */3 */3 */3 */3" do
    base_date = ~N[2003-04-17 04:04:08]
    assert matches_date?(:minute, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date, []) == false
  end

  test "2003-04-17 04:04:08 doesn't match */3 */3 */3 */3 */3 */3" do
    base_date = ~N[2003-04-17 04:04:08]
    assert matches_date?(:second, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:minute, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date, []) == false
  end

  test "2003-04-17 04:04:08Z doesn't match */3 */3 */3 */3 */3 */3" do
    base_date = ~U[2003-04-17 04:04:08Z]
    assert matches_date?(:second, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:minute, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date, []) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date, []) == false
  end

  test "fail on @reboot" do
    base_date = ~N[2003-04-17 04:04:08]

    assert_raise RuntimeError, "Special identifier @reboot is not supported.", fn ->
      matches_date?(%Crontab.CronExpression{reboot: true}, base_date)
    end
  end

  test "DST ambiguity checks correct" do
    normal_date = DateTime.from_naive!(~N[2024-11-28 00:00:00], "Europe/Zurich")

    {:ambiguous, date_earlier, date_later} =
      DateTime.from_naive(~N[2024-10-27 02:30:00], "Europe/Zurich")

    assert matches_date?(~e[* * * * * *]p, date_earlier)
    refute matches_date?(~e[* * * * * *]p, date_later)
    assert matches_date?(~e[* * * * * *]p, normal_date)

    refute matches_date?(~e[* * * * * *]s, date_earlier)
    assert matches_date?(~e[* * * * * *]s, date_later)
    assert matches_date?(~e[* * * * * *]s, normal_date)

    assert matches_date?(~e[* * * * * *]ps, date_earlier)
    assert matches_date?(~e[* * * * * *]ps, date_later)
    assert matches_date?(~e[* * * * * *]ps, normal_date)

    refute matches_date?(~e[* * * * * *], date_earlier)
    refute matches_date?(~e[* * * * * *], date_later)
    assert matches_date?(~e[* * * * * *], normal_date)
  end
end
