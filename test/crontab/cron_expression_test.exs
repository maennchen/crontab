defmodule Crontab.CronExpressionTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Crontab.CronExpression

  doctest Crontab.CronExpression, import: true

  # I'd like to doctest that one, but I can't get the sigil working
  # doctest Inspect.Crontab.CronExpression, import: true

  test "sigil inspect" do
    assert inspect(~e[*]) == "~e[* * * * * *]"
  end

  test "extended sigil inspect" do
    assert inspect(~e[*]e) == "~e[* * * * * * *]e"
  end

  test "earlier sigil inspect" do
    assert inspect(~e[*]p) == "~e[* * * * * *]p"
  end

  test "earlier and later sigil inspect" do
    assert inspect(~e[*]ps) == "~e[* * * * * *]ps"
  end

  test "earlier, later, and extended sigil inspect" do
    assert inspect(~e[*]eps) == "~e[* * * * * * *]eps"
  end
end
