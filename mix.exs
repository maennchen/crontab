defmodule Crontab.Mixfile do
  @moduledoc false

  use Mix.Project

  @version "1.1.10"

  def project do
    [
      app: :crontab,
      version: @version,
      elixir: "~> 1.9",
      build_embedded:
        Mix.env() == :prod or System.get_env("BUILD_EMBEDDED", "false") in ["1", "true"],
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      dialyzer:
        [plt_add_apps: [:ecto]] ++
          if (System.get_env("DIALYZER_PLT_PRIV") || "false") in ["1", "true"] do
            [plt_file: {:no_warn, "priv/plts/dialyzer.plt"}]
          else
            []
          end
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
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
    [
      {:ecto, "~> 1.0 or ~> 2.0 or ~> 3.0", optional: true},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.5", only: [:test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      name: :crontab,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/crontab"}
    ]
  end

  defp docs do
    [
      main: "getting-started",
      source_ref: "v" <> @version,
      source_url: "https://github.com/jshmrtn/crontab",
      extras: [
        "pages/Getting Started.md",
        "CHANGELOG.md",
        "pages/Basic Usage.md"
      ]
    ]
  end
end
