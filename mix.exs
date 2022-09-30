defmodule Automedia.MixProject do
  use Mix.Project

  def project do
    [
      app: :automedia,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp extra_applications(:test), do: [:logger, :mox]
  defp extra_applications(_env), do: [:logger, :postgrex]

  defp deps do
    [
      {:bakeware, runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:mox, ">= 0.0.0", only: :test, runtime: false},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
