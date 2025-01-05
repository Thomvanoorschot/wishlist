defmodule MyDreamGiftsWeb.SetDomain do
  use Phoenix.Component

  def on_mount(_name, _params, _session, socket) do
    domain = Application.get_env(:my_dream_gifts, :domain) || "example.com"

    {:cont, assign(socket, :domain, domain)}
  end
end
