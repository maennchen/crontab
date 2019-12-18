defmodule Crontab.CronExpression.Parser.Utility.List do
  @moduledoc false

  import NimbleParsec

  def list(element),
    do:
      concat(
        repeat(
          concat(
            element,
            "," |> string |> ignore |> label("comma (,)")
          )
        ),
        element
      )

  def space_list(elements) when is_list(elements) do
    elements
    |> Enum.reverse()
    |> Enum.reduce(
      &concat(
        &1,
        choice([
          concat(
            concat(
              ignore(string(" ") |> label("space")),
              &2
            ),
            eos()
          ),
          eos()
        ])
      )
    )
  end
end
