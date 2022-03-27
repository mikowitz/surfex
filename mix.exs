defmodule Surfex.MixProject do
  use Mix.Project

  def project do
    [
      app: :surfex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp compiler_paths(:test), do: ["test/support"] ++ compiler_paths(:prod)
  defp compiler_paths(:dev), do: compiler_paths(:test)
  defp compiler_paths(_), do: ["lib"]
end
