# Crontab

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/crontab/master/LICENSE)
[![Build Status](https://travis-ci.org/jshmrtn/crontab.svg?branch=master)](https://travis-ci.org/jshmrtn/crontab)
[![Hex.pm Version](https://img.shields.io/hexpm/v/crontab.svg?style=flat)](https://hex.pm/packages/crontab)
[![InchCI](https://inch-ci.org/github/jshmrtn/crontab.svg?branch=master)](https://inch-ci.org/github/jshmrtn/crontab)
[![Coverage Status](https://coveralls.io/repos/github/jshmrtn/crontab/badge.svg?branch=master)](https://coveralls.io/github/jshmrtn/crontab?branch=master)

Parse Cron Format Strings, Write Cron Format Strings and Caluclate Execution Dates.

## Installation

  1. Add `crontab` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:crontab, "~> 1.1.2"}]
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
