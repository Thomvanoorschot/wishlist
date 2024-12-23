defmodule CadeauCompasWeb.Live.UserLogin do
  use CadeauCompasWeb, :live_view

  import CadeauCompasWeb.Components.Header
  import SaladUI.{Form, Input, Button, Checkbox}

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    socket =
      socket
      |> assign(form: form)
      |> assign(:current_page, :login_user)
      |> assign(:breadcrumbs, [
        %{name: "Login", link: ~p"/users/log_in"}
      ])

    {:ok, socket}
  end
end
