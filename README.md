# Crontab

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/crontab/master/LICENSE)
![.github/workflows/elixir.yml](https://github.com/jshmrtn/crontab/workflows/.github/workflows/elixir.yml/badge.svg)
[![Hex.pm Version](https://img.shields.io/hexpm/v/crontab.svg?style=flat)](https://hex.pm/packages/crontab)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/crontab/badge.svg?branch=master)](https://coveralls.io/github/jshmrtn/crontab?branch=master)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fjshmrtn%2Fcrontab.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fjshmrtn%2Fcrontab?ref=badge_shield)

Parse Cron Format Strings, Write Cron Format Strings and Calculate Execution Dates.

## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:crontab, "~> 1.1"}]
end
```

  2. Ensure `crontab` is started before your application:

```elixir
def application do
  [applications: [:crontab]]
end
```

## Usage

Please look into the [Documentation](https://hexdocs.pm/crontab/) for usage examples.


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fjshmrtn%2Fcrontab.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fjshmrtn%2Fcrontab?ref=badge_large)