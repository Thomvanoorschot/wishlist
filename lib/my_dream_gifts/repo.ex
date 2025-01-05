defmodule MyDreamGifts.Repo do
  use Ecto.Repo,
    otp_app: :my_dream_gifts,
    adapter: Ecto.Adapters.Postgres
end
