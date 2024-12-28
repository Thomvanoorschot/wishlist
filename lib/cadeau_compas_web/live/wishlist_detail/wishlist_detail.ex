defmodule CadeauCompasWeb.Live.WishlistDetail do
  use CadeauCompasWeb, :live_view

  alias CadeauCompas.Wishlist

  def mount(%{"username" => username, "wishlist_slug" => slug}, _session, socket) do
    %{id: user_id} = socket.assigns.current_user
    wishlists = Wishlist.get_detail_with_products(username, slug)

    IO.inspect(wishlists)

    socket =
      socket
      |> assign(:current_page, :wishlist_detail)

    {:ok, socket}
  end
end
