defmodule Crontab.DateCheckerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Crontab.DateChecker

  import Crontab.DateChecker

  test "2002-01-13 23:00:07 matches * * * * *" do
    base_date = ~N[2002-01-13 23:00:07]
    assert matches_date?(:minute, [:*], base_date) == true
    assert matches_date?(:hour, [:*], base_date) == true
    assert matches_date?(:day, [:*], base_date) == true
    assert matches_date?(:month, [:*], base_date) == true
    assert matches_date?(:weekday, [:*], base_date) == true
    assert matches_date?(:year, [:*], base_date) == true
  end

  test "2002-01-13 23:00:07Z matches * * * * *" do
    base_date = ~U[2002-01-13 23:00:07Z]
    assert matches_date?(:minute, [:*], base_date) == true
    assert matches_date?(:hour, [:*], base_date) == true
    assert matches_date?(:day, [:*], base_date) == true
    assert matches_date?(:month, [:*], base_date) == true
    assert matches_date?(:weekday, [:*], base_date) == true
    assert matches_date?(:year, [:*], base_date) == true
  end

  test "2004-04-16 04:04:08 matches */4 */4 */4 */5 */4" do
    base_date = ~N[2004-04-16 04:04:08]
    assert matches_date?(:second, [{:/, :*, 4}], base_date) == true
    assert matches_date?(:minute, [{:/, :*, 4}], base_date) == true
    assert matches_date?(:hour, [{:/, :*, 4}], base_date) == true
    assert matches_date?(:day, [{:/, :*, 4}], base_date) == true
    assert matches_date?(:month, [{:/, :*, 4}], base_date) == true
    assert matches_date?(:weekday, [{:/, :*, 5}], base_date) == true
    assert matches_date?(:year, [{:/, :*, 4}], base_date) == true
  end

  test "2003-04-17 04:04:08 doesn't match */3 */3 */3 */3 */3" do
    base_date = ~N[2003-04-17 04:04:08]
    assert matches_date?(:minute, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date) == false
  end

  test "2003-04-17 04:04:08 doesn't match */3 */3 */3 */3 */3 */3" do
    base_date = ~N[2003-04-17 04:04:08]
    assert matches_date?(:second, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:minute, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date) == false
  end

  test "2003-04-17 04:04:08Z doesn't match */3 */3 */3 */3 */3 */3" do
    base_date = ~U[2003-04-17 04:04:08Z]
    assert matches_date?(:second, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:minute, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:hour, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:day, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:month, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:weekday, [{:/, :*, 3}], base_date) == false
    assert matches_date?(:year, [{:/, :*, 3}], base_date) == false
  end

  test "fail on @reboot" do
    base_date = ~N[2003-04-17 04:04:08]

    assert_raise RuntimeError, "Special identifier @reboot is not supported.", fn ->
      matches_date?(%Crontab.CronExpression{reboot: true}, base_date)
    end
  end
end
