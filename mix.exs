defmodule ConfigHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :config_helpers,
      version: "1.0.0",
      elixir: "~> 1.13",
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
      files: ~w(lib .formatter.exs mix.exs README.md),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/box-id/config_helpers"}
    ]
  end
end
