defmodule Livre.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        LivreWeb.Telemetry,
        Livre.Repo,
        {DNSCluster, query: Application.get_env(:livre, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Livre.PubSub},
        # Start the Finch HTTP client (also used to send emails)
        {Finch, name: Livre.Finch},
        # Start to serve requests, typically the last entry
        LivreWeb.Endpoint
      ]
      |> with_contextual_children(Mix.env())

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Livre.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivreWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp with_contextual_children(children, env) when env in [:test, :dev] do
    children ++
      [
        # Starting a mock server in dev & test
        {Plug.Cowboy, scheme: :http, plug: LivreTest.ApiMock, options: [port: 14000]}
      ]
  end

  defp with_contextual_children(children, _env), do: children
end
