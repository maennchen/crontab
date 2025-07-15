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

  test "earlier sigil inspect" do
    assert inspect(~e[*]a) == "~e[* * * * * *]a"
  end

  test "earlier and later sigil inspect" do
    assert inspect(~e[*]al) == "~e[* * * * * *]al"
  end

  test "earlier, later, and extended sigil inspect" do
    assert inspect(~e[*]eal) == "~e[* * * * * * *]ale"
  end
end
