if Code.ensure_compiled?(Timex) do
  defmodule Crontab.DateLibrary.Timex do
    @moduledoc false

    @behaviour Crontab.DateLibrary

    def shift(date, amount, unit) do
      Timex.shift(date, [{unit, amount}])
    end
  end
end
