defmodule Crontab.CronExpressionTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Crontab.CronExpression, import: true

  import Crontab.CronExpression

  # I'd like to doctest that one, but I can't get the sigil working
  # doctest Inspect.Crontab.CronExpression, import: true

  test "sigil inspect" do
    assert inspect(~e[*]) == "~e[* * * * * *]"
  end

  test "extended sigil inspect" do
    assert inspect(~e[*]e) == "~e[* * * * * * *]e"
  end
end
