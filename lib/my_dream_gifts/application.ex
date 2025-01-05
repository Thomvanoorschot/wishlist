defmodule MyDreamGifts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    maybe_install_ecto_dev_logger()

    children = [
      MyDreamGiftsWeb.Telemetry,
      MyDreamGifts.Repo,
      {DNSCluster, query: Application.get_env(:my_dream_gifts, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyDreamGifts.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MyDreamGifts.Finch},
      # Start a worker by calling: MyDreamGifts.Worker.start_link(arg)
      # {MyDreamGifts.Worker, arg},
      # Start to serve requests, typically the last entry
      MyDreamGiftsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyDreamGifts.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyDreamGiftsWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  if Code.ensure_loaded?(Ecto.DevLogger) do
    defp maybe_install_ecto_dev_logger, do: Ecto.DevLogger.install(MyDreamGifts.Repo)
  else
    defp maybe_install_ecto_dev_logger, do: :ok
  end
end
