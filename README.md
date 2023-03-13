# ConfigHelpers

Utility function for writing cleaner `runtime.exs` configs by avoiding branching by `config_env()`.

[![Tests](https://github.com/box-id/config_helpers/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/box-id/config_helpers/actions/workflows/ci.yml)

## Problem

When developing an application in the `:dev` environment, testing it in `:test` and shipping it in `:prod`, various bits
of configuration may need to be loaded from environment. In some environments, certain variables might be optional and
have defaults that work in most situations, but should still be configurable. In production however, a default such as
`DB_HOST=localhost` might be dangerous, so the application should enforce that a value is specified.

While `runtime.exs` allows choosing between `System.get_env("KEY", "default")` and `System.fetch_env!("KEY")` depending on `config_env()`, this quickly becomes repetitive.

## Solution

This package solves the problem by providing a `get_env` function to be used in `runtime.exs` which requires an environment variable to be set only if no default is provided for the current env.

### Defaults

This example shows how default values can be specified:

```elixir
import Config
import ConfigHelpers

config :my_app, MQTT,
  # A default exists for all environments.
  port: get_env("MQTT_PORT", default: "1883"),
  # Same behavior as above, providing a single value instead of a list is equal to `default: <value>`.
  client_prefix: get_env("MQTT_PREFIX", "my_app_"),
  # Defaults can be set for some environments only, requiring it in others.
  host: get_env("MQTT_HOST", dev: "localhost", test: "localhost"),
  # Samve as above, as `non_prod` is an alias for `dev` and `test`.
  auth: get_env("MQTT_AUTH", non_prod: "dummy"),
```

### Types

Sometimes, modules need their configuration as integer or boolean values, requiring the developer to explicitly cast
them. Thus, `get_env` has built-in support for casting values:

```elixir
import Config
import ConfigHelpers

config :my_app, MQTT,
  # `as:` can be used to cast values (both from environment and defaults) to `:integer` or `:boolean`.
  port: get_env("MQTT_PORT", "1883", as: :integer),
  # If the first given default value is an integer or a boolean, values will automatically be cast to that type.
  timeout: get_env("MQTT_TIMEOUT", 30),
  # Accepts values such as "true", "TRUE", "1"
  auto_reconnect: get_env("MQTT_RECONNECT", false)
```

## Installation

The package can be installed by adding `config_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:config_helpers, "~> 0.1.0"}
  ]
end
```

This package follows semantic versioning.
