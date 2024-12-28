defmodule CadeauCompasWeb.Live.WishlistDetail do
  use CadeauCompasWeb, :live_view

  import CadeauCompasWeb.Components.{WishlistList}

  alias CadeauCompas.Wishlist

  def mount(%{"username" => username, "wishlist_slug" => slug}, _session, socket) do
    %{id: user_id} = socket.assigns.current_user
    wishlist = Wishlist.get_detail_with_products(username, slug)

    IO.inspect(wishlist)

    socket =
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:current_page, :wishlist_detail)

    {:ok, socket}
  end
end
