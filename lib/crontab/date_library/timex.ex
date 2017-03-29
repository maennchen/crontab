if Code.ensure_compiled?(Timex) do
  defmodule Crontab.DateLibrary.Timex do
    @moduledoc false

    @behaviour Crontab.DateLibrary

    def shift(date, amount, unit) do
      Timex.shift(date, [{unit, amount}])
    end

    defdelegate beginning_of_year(date), to: Timex

    defdelegate end_of_year(date), to: Timex

    defdelegate beginning_of_month(date), to: Timex

    defdelegate end_of_month(date), to: Timex

    defdelegate beginning_of_day(date), to: Timex

    defdelegate end_of_day(date), to: Timex
  end
end
