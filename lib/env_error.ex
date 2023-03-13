defmodule ConfigHelpers.EnvError do
  @moduledoc """
  Error raised when vairable does not exist in environment and no default could be found for current env.
  """

  defexception [:var, :env]

  @impl true
  def message(%{var: var, env: env}) do
    "could not fetch environment variable #{inspect(var)} because it is not set and no default for env \"#{inspect(env)}\" exists"
  end
end
