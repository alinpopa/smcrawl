defmodule Smcrawl.CLI.MixProject do
  use Mix.Project

  def project do
    [
      app: :smcrawl_cli,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: Smcrawl.CLI]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:smcrawl_lib, in_umbrella: true}
    ]
  end
end
