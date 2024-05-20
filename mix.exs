defmodule RandomWord.MixProject do
  use Mix.Project

  def project do
    [
      app: :random_word,
      version: "0.1.0",
      elixir: "~> 1.16.2",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:arrays, "~> 2.0"},
      {:arrays_aja, "~> 0.2.0"}
    ]
  end
end
