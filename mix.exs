defmodule LogisticMap2.MixProject do
  use Mix.Project

  def project do
    [
      app: :logistic_map2,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "Benchmark of Logistic Map using integer calculation.",
      package: [
        maintainers: ["Susumu Yamazaki"],
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/zeam-vm/logistic_map2"}
      ],
      compilers: [:rustler] ++ Mix.compilers,
      rustler_crates: rustler_crates(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp rustler_crates() do
    [
      logistic_map2_nif: [
        path: "native/logisticmap2nif",
        mode: :release,
      ]
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
      {:flow, "~> 0.14.0"},
      {:rustler, "~> 0.18.0"}
    ]
  end
end
