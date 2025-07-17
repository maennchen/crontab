defmodule Crontab.CronExpression.ComposerTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Crontab.CronExpression.Composer
  alias Crontab.CronExpression.Parser

  doctest Composer

  test "works" do
    specific_cron = "*/15 9-17 5-19 2-8 SUN 2012-2015"
    cron_expression = Parser.parse!(specific_cron)
    assert "*/15 9-17 5-19 2-8 7 2012-2015" == Composer.compose(cron_expression)
  end

  test "works with skip year flag" do
    specific_cron = "*/15 9-17 5-19 2-8 SUN 2012-2015"
    cron_expression = Parser.parse!(specific_cron)
    assert "*/15 9-17 5-19 2-8 7" == Composer.compose(cron_expression, %{skip_year: true})
  end
end
