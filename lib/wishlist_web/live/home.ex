defmodule WishlistWeb.Home do
  use WishlistWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:current_page, :home)
      |> assign(:breadcrumbs, [
        %{name: "Home", link: ~p"/"}
      ])

    {:ok, socket}
  end

  def handle_event("edit_item", %{"id" => id}, socket) do
    item = Enum.find(socket.assigns.items, fn item -> item.id == String.to_integer(id) end)
    {:noreply, assign(socket, editing_item: item)}
  end
end
