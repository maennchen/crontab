defmodule Crontab.CronExpressionTest do
  use ExUnit.Case, async: true
  doctest Crontab.CronExpression, import: true

  # I'd like to doctest that one, but I can't get the sigil working
  # doctest Inspect.Crontab.CronExpression, import: true
end
