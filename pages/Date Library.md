# Date Library

This library can be used independent from `timex`.

Any date library can be used by implementing the `Crontab.DateLibrary` behavior.

**The library does not respect semver for this behaviour. Breaking Changes will
happen even in patch releases.**

To use another date library, change the implementation like this:

```elixir
config :crontab,
  date_library: Crontab.DateLibrary.Timex
```
