defmodule CadeauCompasWeb.Live.WishlistDetail do
  use CadeauCompasWeb, :live_view

  def mount(%{"username" => username, "wishlist_name" => wishlist_name}, _session, socket) do
    %{id: user_id} = socket.assigns.current_user
    # wishlists = Wishlist.get_with_products(user_id)

    socket =
      socket
      |> assign(:current_page, :wishlist_detail)

    {:ok, socket}
  end
end
