defmodule CadeauCompasWeb.Live.Lander do
  use CadeauCompasWeb, :live_view

  import SaladUI.{Button, Card, Input}
  import CadeauCompasWeb.Components.CustomDialog

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:current_page, :lander)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    default_modal? = Map.get(params, "modal")

    if default_modal? do
      socket =
        push_event(socket, "open_modal", %{
          id: "log_in_register_dialog"
        })

      {:noreply, assign(socket, default_tab: default_modal?)}
    else
      {:noreply, socket}
    end
  end
end
