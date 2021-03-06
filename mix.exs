defmodule QRCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_qrcode,
      description: "Utils for generating QR code in Elixir",
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/2players/ex_qrcode",
      deps: deps(),
      package: package(),
      docs: docs()
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
      # prevent mix from trying to loading the package application file
      # https://stackoverflow.com/a/43639173
      {:qrcode, github: "komone/qrcode", ref: "4f74760", app: false, compile: "erl -make"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md"
      ]
    ]
  end

  def package do
    [
      maintainers: ["m31271n"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/2players/ex_qrcode"}
    ]
  end
end
