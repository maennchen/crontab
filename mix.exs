defmodule Crontab.Mixfile do
  use Mix.Project

  @version "1.1.2"

  def project do
    [app: :crontab,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     docs: docs(),
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    Parse Cron Format Strings, Write Cron Format Strings and Calculate Execution Dates.
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
    [{:ecto, "~> 1.0 or ~> 2.0 or ~> 2.1", optional: true},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:inch_ex, only: :docs},
     {:excoveralls, "~> 0.4", only: [:dev, :test]},
     {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
     {:credo, "~> 0.5", only: [:dev, :test]}]
  end

  defp package do
    [# These are the default files included in the package
     name: :crontab,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Jonatan Männchen"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/jshmrtn/crontab"}]
  end

  defp docs do
    [main: "getting-started",
     source_ref: "v" <> @version,
     source_url: "https://github.com/jshmrtn/crontab",
     extras: [
       "pages/Getting Started.md",
       "CHANGELOG.md",
       "pages/Basic Usage.md",
    ]]
  end
end
