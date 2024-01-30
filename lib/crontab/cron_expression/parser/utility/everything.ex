defmodule Crontab.CronExpression.Parser.Utility.Everything do
  @moduledoc false

  import NimbleParsec

  def everything do
    string("*") |> replace(:*) |> label("wildcard (*)")
  end
end
