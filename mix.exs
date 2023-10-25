defmodule Automedia.MixProject do
  use Mix.Project
  @app :automedia

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: Mix.env() != :test,
      releases: [{@app, release()}],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        release: :prod
      ]
    ]
  end

  def application do
    application = [
      extra_applications: extra_applications(Mix.env()),
    ]

    build_cli = System.get_env("BUILD_BAKEWARE")
    if build_cli do
      [{:mod, {Automedia.CLI, []}} | application]
    else
      application
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp extra_applications(:test), do: [:logger, :mox]
  defp extra_applications(_env), do: [:logger, :postgrex]

  defp deps do
    [
      {:bakeware, ">= 0.0.0", runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:mox, ">= 0.0.0", only: :test, runtime: false},
      {:postgrex, ">= 0.0.0"}
    ]
  end

  defp release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      quiet: true,
      steps: [:assemble, &Bakeware.assemble/1],
      strip_beams: Mix.env() == :prod
    ]
  end
end
