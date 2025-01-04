defmodule CadeauCompas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    maybe_install_ecto_dev_logger()

    children = [
      CadeauCompasWeb.Telemetry,
      CadeauCompas.Repo,
      {DNSCluster, query: Application.get_env(:cadeau_compas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CadeauCompas.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CadeauCompas.Finch},
      # Start a worker by calling: CadeauCompas.Worker.start_link(arg)
      # {CadeauCompas.Worker, arg},
      # Start to serve requests, typically the last entry
      CadeauCompasWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CadeauCompas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CadeauCompasWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  if Code.ensure_loaded?(Ecto.DevLogger) do
    defp maybe_install_ecto_dev_logger, do: Ecto.DevLogger.install(CadeauCompas.Repo)
  else
    defp maybe_install_ecto_dev_logger, do: :ok
  end
end
