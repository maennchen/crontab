# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Do not link the versions in the title since this is not compatible with ExDoc. -->

## Unreleased

Diff for [unreleased](https://github.com/jshmrtn/crontab/compare/v1.1.7...HEAD)

## 1.1.7

### Added

* Improved Validation of the Parser

Diff for [v1.1.7](https://github.com/jshmrtn/crontab/compare/v1.1.6...v1.1.7)

## 1.1.6

### Fixed

* Do not skip month in date util skip_month.

Diff for [v1.1.6](https://github.com/jshmrtn/crontab/compare/v1.1.5...v1.1.6)

## 1.1.5

### Added

* Compatibility for Ecto 3.0

Diff for [v1.1.5](https://github.com/jshmrtn/crontab/compare/v1.1.4...v1.1.5)

## 1.1.4

### Fixed

* Fast fail on impossible year scenarios (#51)

Diff for [v1.1.4](https://github.com/jshmrtn/crontab/compare/v1.1.3...v1.1.4)

## 1.1.3

* Fixed Typos
* Fixed run limits

Diff for [v1.1.3](https://github.com/jshmrtn/crontab/compare/v1.1.2...v1.1.3)

## 1.1.2

### Fixed

* Microsecond Precision Scheduler Fix

Diff for [v1.1.2](https://github.com/jshmrtn/crontab/compare/v1.1.1...v1.1.2)

## 1.1.1

### Fixed

* Date Library independent

Diff for [v1.1.1](https://github.com/jshmrtn/crontab/compare/v1.1.0...v1.1.1)

## 1.1.0

### Added

* Date Library independent

Diff for [v1.1.0](https://github.com/jshmrtn/crontab/compare/v1.0.0...v1.1.0)

## 1.0.0

### Removed

 * Removed Helper Functions in Module `Crontab`

### Changed
 * Moved `get_[next|previous]_run_dates` to `Crontab.Scheduler`
 * Renamed Modules to a better name
 * Renamed function to conventions. (`?` for booleans, `!` for functions that raise errors)

### Added
 * Introduction of `~e[CRON_EXPRESSION]` sigil
 * Introduced Ecto Type

Diff for [v1.0.0](https://github.com/jshmrtn/crontab/compare/v0.8.5...v1.0.0)
