defmodule Attio.MixProject do
  use Mix.Project

  @repo_url "https://github.com/sgerrand/ex_attio"
  @version "0.3.3"

  def project do
    [
      app: :attio,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Keep the core Erlang/Elixir PLTs next to the project PLT in _build
      # (instead of ~/.mix) so CI's _build cache covers all of them.
      dialyzer: [plt_core_path: "_build/#{Mix.env()}"],
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
      extra_applications: []
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:req, "~> 0.5"},
      {:excoveralls, "~> 0.18", only: :test},
      {:plug, "~> 1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
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
