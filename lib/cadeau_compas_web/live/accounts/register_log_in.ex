defmodule CadeauCompasWeb.Live.RegisterLogIn do
  use CadeauCompasWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(default_tab: socket.assigns.live_action || "log_in")
      |> assign(:current_page, :register_user)

    {:ok, socket}
  end
end
