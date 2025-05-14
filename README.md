# ConfigHelpers

Utility function for writing cleaner `runtime.exs` configs by avoiding branching by `config_env()`.

[![Hex](https://img.shields.io/hexpm/v/config_helpers.svg)](https://hex.pm/packages/config_helpers)
[![Tests](https://github.com/box-id/config_helpers/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/box-id/config_helpers/actions/workflows/ci.yml)

- [Install from Hex](https://hex.pm/packages/config_helpers)
- [Documentation available on hexdoc](https://hexdocs.pm/config_helpers)
- [Source code on GitHub](https://github.com/box-id/config_helpers)

## Problem

When developing an application in the `:dev` environment, testing it in `:test` and shipping it in `:prod`, various bits
of configuration may need to be loaded from environment. In some environments, certain variables might be optional and
have defaults that work in most situations, but should still be configurable. In production however, a default such as
`DB_HOST=localhost` might be dangerous, so the application should enforce that a value is specified.

While `runtime.exs` allows choosing between `System.get_env("KEY", "default")` and `System.fetch_env!("KEY")` depending
on `config_env()`, this quickly becomes repetitive.

## Solution

This package solves the problem by providing a `get_env` function to be used in `runtime.exs` which requires an
environment variable to be set only if no default is provided for the current env.

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
  # Same as above, since `non_prod` is an alias for `dev` and `test`.
  auth: get_env("MQTT_AUTH", non_prod: "dummy"),
```

#### Empty Variables

For `System.get_env/2`, empty environment variables (returned as empty strings) count as being set. This can be
intentional, but it can also happen by accident at shell level when exporting undefined variables.

To avoid mistakes, we've chosen to require explicit opt in to allow empty variables using the `allow_empty: true`
option. By default, empty environment variables count as nonexistent.

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

### Disabling Individual Environment Keys

In production, services are often intentionally configured to fail when required environment variables are missing. This ensures that critical features are not silently disabled due to a misconfiguration. However, when running the same production build in other environments (e.g. test/local development), it is often necessary to start the service without production-only keys.

To support this, version `1.1.0` introduced a convention: setting the `DISABLED_<original_key>` environment variable. If set to a truthy value, it will:

- Instruct the `get_env` to treat the corresponding `<original_key>` as **disabled**, even if it is present.
- Prevent startup failures due to missing `<original_key>`.
- Override the `<original_key>`'s value to `nil`, instructing the application to not execute the relevant behavior (including checking validity of the configured value)

Example:

```bash
# Disable the requirement for MQTT_PORT
export DISABLED_MQTT_PORT=true
```

## Installation

The package can be installed by adding `config_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:config_helpers, "~> 1.1.0"}
  ]
end
```

This package follows semantic versioning.
