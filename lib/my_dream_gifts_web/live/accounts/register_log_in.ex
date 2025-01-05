defmodule MyDreamGiftsWeb.Live.RegisterLogIn do
  use MyDreamGiftsWeb, :live_view

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    login_error = Phoenix.Flash.get(socket.assigns.flash, :login_error)

    socket =
      socket
      |> assign(email: email)
      |> assign(login_error: login_error)
      |> assign(default_tab: to_string(socket.assigns.live_action || :log_in))
      |> assign(:current_page, :register_user)

    {:ok, socket}
  end
end
