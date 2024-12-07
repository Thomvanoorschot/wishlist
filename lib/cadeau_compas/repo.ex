defmodule CadeauCompas.Repo do
  use Ecto.Repo,
    otp_app: :cadeau_compas,
    adapter: Ecto.Adapters.Postgres
end
