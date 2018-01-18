defmodule Crontab.CronExpressionTest do
  import Crontab.CronExpression

  use ExUnit.Case, async: true
  doctest Crontab.CronExpression, import: true

  import ExUnit.CaptureIO

  # I'd like to doctest that one, but I can't get the sigil working
  # doctest Inspect.Crontab.CronExpression, import: true

  test "sigil inspect" do
    fun = fn ->
      assert IO.inspect(~e[*])
    end

    assert capture_io(fun) == "~e[* * * * * *]\n"
  end

  test "extended sigil inspect" do
    fun = fn ->
      assert IO.inspect(~e[*]e)
    end

    assert capture_io(fun) == "~e[* * * * * * *]e\n"
  end
end
