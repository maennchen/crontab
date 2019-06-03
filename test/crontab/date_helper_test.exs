defmodule Crontab.DateHelperTest do
  use ExUnit.Case, async: true
  doctest Crontab.DateHelper

  describe "inc_month/1" do
    test "does not jump obver month" do
      assert Crontab.DateHelper.inc_month(~N[2019-05-31 23:00:00]) == ~N[2019-06-01 23:00:00]
    end
  end
end
