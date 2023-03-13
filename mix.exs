defmodule ConfigHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :config_helpers,
      version: "0.1.0",
      elixir: "~> 1.11",
      deps: deps(),
      # There is no build-time configuration, so share the build results between environments.
      build_per_environment: false,
      description: description(),
      package: package(),
      docs: [
        name: "ConfigHelpers",
        main: "readme",
        source_url: "https://github.com/box-id/config_helpers",
        extras: ["README.md"]
      ]
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29.2", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Utility function for writing cleaner `runtime.exs` configs."
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/box-id/config_helpers"}
    ]
  end
end
