defmodule CadeauCompasWeb.Live.Lander do
  use CadeauCompasWeb, :live_view

  import SaladUI.{Button, Card, Input}

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_page, :lander)

    {:ok, socket}
  end
end
