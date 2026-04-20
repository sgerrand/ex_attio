defmodule Attio.MixProject do
  use Mix.Project

  @repo_url "https://github.com/sgerrand/ex_attio"
  @version "0.2.0"

  def project do
    [
      app: :attio,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],

      # Hex
      description: "Elixir client for the Attio API",
      package: %{
        licenses: ["BSD-2-Clause"],
        links: %{
          GitHub: @repo_url,
          Changelog: "https://hexdocs.pm/attio/changelog.html"
        }
      },

      # Docs
      name: "Attio",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.lcov": :test
      ]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:excoveralls, "~> 0.18", only: :test},
      {:plug, "~> 1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
