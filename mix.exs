defmodule Relisa.Mixfile do
  use Mix.Project

  def project do
    [app: :relisa,
     version: "0.1.0",
     elixir: "~> 1.0",
     description: "Fast, simple, and composable deployment library for Elixir.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/SenecaSystems/relisa",
     deps: deps,
     package: package]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["Seneca Systems"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/SenecaSystems/relisa"}
    ]
  end

  defp deps do
    [{:exrm, "~> 1.0.0"}]
  end
end
