defmodule RandomPassword.MixProject do
  use Mix.Project

  def project do
    [
      app: :random_password,
      version: "1.2.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp deps,
    do: [
      {:puid, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]

  defp description do
    """
    Efficiently generate cryptographically strong random passwords using alpha (including Unicode), numeric and special symbols.
    """
  end

  defp package do
    [
      maintainers: ["Paul Rogers"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/RandomPassword/Elixir",
        "README" => "https://randompassword.github.io/Elixir/",
        "Docs" => "https://hexdocs.pm/random_password/api-reference.html"
      }
    ]
  end
end
