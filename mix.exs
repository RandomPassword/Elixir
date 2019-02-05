defmodule RandomPassword.MixProject do
  use Mix.Project

  def project do
    [
      app: :random_password,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application, do: []

  defp deps, do:
    [
      {:puid, "~> 1.0"},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]

  defp description do
    """
    Efficiently generate cryptographically strong random passwords using alpha, numeric and special symbols.
    """
  end

  defp package do
    [
      maintainers: ["Paul Rogers"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/RandomPassword/Elixir"}
    ]
  end  
end
