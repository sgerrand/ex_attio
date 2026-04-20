defmodule Attio.MixProject do
  use Mix.Project

  def project do
    [
      app: :attio,
      version: "0.1.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir client for the Attio API",
      package: %{
        licenses: ["BSD-2-Clause"],
        links: %{GitHub: "https://github.com/sgerrand/ex_attio"}
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:plug, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
