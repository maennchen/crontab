defmodule Crontab.Mixfile do
  use Mix.Project

  def project do
    [app: :crontab,
     version: "0.7.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :timex]]
  end

  defp description do
    """
    Parse Cron Format Strings, Write Cron Format Strings and Caluclate Execution Dates.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:timex, "~> 3.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:inch_ex, only: :docs},
     {:excoveralls, "~> 0.4", only: [:dev, :test]},
     {:dialyxir, "~> 0.4", only: [:dev], runtime: false}]
  end

  defp package do
    [# These are the default files included in the package
     name: :crontab,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Jonatan Männchen"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/sk-t/crontab"}]
  end
end
