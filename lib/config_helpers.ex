defmodule ConfigHelpers do
  @moduledoc """
  Module to be imported by `runtime.exs` to allow acessing the `get_env` function.

  Note that functions of this module are not supposed to be called by regular applicaton code since they use
  `Config.config_env()` which is only possible while reading config files.
  """
  require Config

  @accepted_true_values ~w(true True TRUE yes YES t T 1)

  @doc """
  3-arity clause needed to support single default value for all envs together with options list. See `get_env/2` for
  documentation.
  """
  def get_env(key, default, opts) when not is_list(default) and is_list(opts) do
    get_env(key, [default: default] ++ opts)
  end

  @doc """
  Read configuration from an environment variables while providing defaults for some envs.

  Defaults can be given as keyword list or single value (equivalent to `default: <value>`). If the given `key` is
  not set in the environment (empty string counts as being set), default keys are checked in the following order:

  1. Current env, e.g. `:dev`, `:test` or `:prod`
  2. `:non_prod`, if current env is `:dev` or `:test`
  3. `:default`

  If no value can be found, `ConfigHelpers.EnvError` is raised.

  The following options can be added to the defaults list:

  * `as:` Typecast values to `:integer` or `:boolean`
    * For `:boolean`, the following values are considered truthy: `#{inspect(@accepted_true_values)}`
    * For `:integer`, passing a value that fails conversion using `String.to_integer/1` causes `ArgumentError` to be raised.
  """
  def get_env(key, defaults \\ [])

  def get_env(key, default) when not is_list(default) do
    get_env(key, default: default)
  end

  def get_env(key, defaults) do
    case System.fetch_env(key) do
      {:ok, value} ->
        value

      :error ->
        find_default(key, defaults)
    end
    |> maybe_cast(defaults, key)
  end

  defp find_default(key, defaults) do
    env = target_env()

    with :error <- Keyword.fetch(defaults, env),
         :error <- maybe_fetch_non_prod(defaults, env),
         :error <- Keyword.fetch(defaults, :default) do
      raise __MODULE__.EnvError, var: key, env: env
    else
      {:ok, value} ->
        value
    end
  end

  defp target_env() do
    Config.config_env()
  end

  defp maybe_fetch_non_prod(_defaults, :prod), do: :error
  defp maybe_fetch_non_prod(defaults, _env), do: Keyword.fetch(defaults, :non_prod)

  defp maybe_cast(value, options, key) do
    case Keyword.fetch(options, :as) do
      {:ok, :integer} ->
        cast_to_integer(value, key)

      {:ok, :boolean} ->
        cast_to_boolean(value)

      {:ok, other} ->
        raise "unexpected type specified for 'get_env(..., as:)': #{inspect(other)}"

      :error ->
        try_infer_cast(value, options, key)
    end
  end

  defp try_infer_cast(value, options, key) do
    case List.first(options) do
      {_key, default} when is_integer(default) ->
        cast_to_integer(value, key)

      {_key, default} when is_boolean(default) ->
        cast_to_boolean(value)

      _ ->
        value
    end
  end

  defp cast_to_integer(value, _key) when is_integer(value), do: value

  defp cast_to_integer(value, key) when is_binary(value) do
    String.to_integer(value)
  rescue
    ArgumentError ->
      reraise %ArgumentError{
                message:
                  "unable to convert #{inspect(value)} to integer for env variable #{inspect(key)}"
              },
              __STACKTRACE__
  end

  defp cast_to_boolean(value) when is_boolean(value), do: value

  defp cast_to_boolean(value) when is_binary(value), do: value in @accepted_true_values
end
