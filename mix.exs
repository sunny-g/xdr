defmodule XDR.Mixfile do
  use Mix.Project

  @name    :xdr
  @version "0.2.0"

  @deps [
    {:math, "~> 0.3.0"},
    {:ok,   github: "sunny-g/ok"},
  ]

  @dev_deps [
    {:credo,          "~> 0.8", only: [:dev, :test], runtime: false},
    {:ex_doc,         ">0.0.0", only: [:dev, :test], runtime: false},
    {:mix_test_watch, "~> 0.3", only: [:dev, :test], runtime: false},
  ]

  @maintainers ["Sunny G"]
  @github      "https://github.com/sunny-g/xdr"

  @description """
  XDR encoded data structures (RFC 4506) in Elixir
  """

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod

    [ app:              @name,
      version:          @version,
      elixir:           "~> 1.6",
      deps:             @deps ++ @dev_deps,
      build_embedded:   in_production,
      start_permanent:  in_production,
      description:      @description,
      docs: [
        main:           "readme",
        source_url:     @github,
        extras:         ["README.md"],
      ],
      package:          package(),
    ]
  end

  def application do
      # built-in apps that need starting
    [ extra_applications: [
        :logger,
      ],
    ]
  end

  defp package do
    [ name:        @name,
      files:       ["lib", "mix.exs", "README.md"],
      maintainers: @maintainers,
      licenses:    ["MIT"],
      links:       %{
        "GitHub" => @github,
      },
    ]
  end
end
