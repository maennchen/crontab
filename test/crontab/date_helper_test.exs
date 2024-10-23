defmodule Crontab.DateHelperTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Crontab.DateHelper

  describe "nth_weekday/3" do
    refute Crontab.DateHelper.nth_weekday(~N[2024-11-01 00:00:00], 1, 5)
    assert Crontab.DateHelper.nth_weekday(~N[2024-12-01 00:00:00], 1, 5) == 30
    assert Crontab.DateHelper.nth_weekday(~N[2024-09-01 00:00:00], 1, 5) == 30
  end

  describe "inc_month/1" do
    test "does not jump obver month" do
      assert Crontab.DateHelper.inc_month(~N[2019-05-31 23:00:00]) == ~N[2019-06-01 23:00:00]
    end
  end
end
