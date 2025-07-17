if match?({:module, Ecto.Type}, Code.ensure_compiled(Ecto.Type)) do
  defmodule Crontab.CronExpression.Ecto.TypeTest do
    @moduledoc false

    use ExUnit.Case, async: false

    doctest Crontab.CronExpression.Ecto.Type

    alias Crontab.CronExpression.Ecto.Type

    import Crontab.CronExpression

    test "type/0" do
      assert Type.type() == :map
    end

    test "cast/1 String" do
      assert Type.cast("*") == {:ok, ~e[*]}
    end

    test "cast/1 String with whitespace" do
      assert Type.cast("* ") == {:ok, ~e[*]}
      assert Type.cast(" * ") == {:ok, ~e[*]}
      assert Type.cast(" *") == {:ok, ~e[*]}
    end

    test "cast/1 CronExpression" do
      assert Type.cast(~e[*]) == {:ok, ~e[*]}
      assert Type.cast(~e[*]ps) == {:ok, ~e[*]ps}
    end

    test "cast/1 other" do
      assert Type.cast([]) == :error
    end

    test "load/1 map" do
      assert Type.load(%{extended: false, expression: "* * * * *"}) == {:ok, ~e[*]}
      assert Type.load(%{extended: true, expression: "* * * * * *"}) == {:ok, ~e[*]e}

      assert Type.load(%{
               extended: true,
               expression: "* * * * * *",
               prior: true,
               subsequent: true
             }) == {:ok, ~e[*]eps}

      assert Type.load(%{extended: false, expression: "*/9"}) == {:ok, ~e[*/9]}

      assert Type.load(%{
               "extended" => false,
               "expression" => "*/9",
               "prior" => true,
               "subsequent" => false
             }) == {:ok, ~e[*/9]p}
    end

    test "load/1 other" do
      assert Type.load([]) == :error
    end

    test "dump/1 CronExpression" do
      assert Type.dump(~e[*]) ==
               {:ok,
                %{expression: "* * * * * *", extended: false, prior: false, subsequent: false}}

      assert Type.dump(~e[*]eps) ==
               {:ok,
                %{expression: "* * * * * * *", extended: true, prior: true, subsequent: true}}
    end

    test "dump/1 other" do
      assert Type.dump([]) == :error
    end
  end
end
