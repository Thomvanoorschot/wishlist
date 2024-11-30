defmodule WishlistWeb.Dashboard do
  use WishlistWeb, :live_view

  alias Wishlist.Product
  alias Wishlist.Wishlist

  import WishlistWeb.SearchModal
  import SaladUI.Button
  import SaladUI.Card
  import SaladUI.Accordion
  import SaladUI.Input
  import SaladUI.Form

  def mount(_params, _session, socket) do
    wishlists = Wishlist.get_with_products()

    socket =
      socket
      |> assign(:search_entries, [])
      |> assign(:wishlists, wishlists)
      |> assign(:current_page, :dashboard)
      |> assign(:breadcrumbs, [
        %{name: "Dashboard", link: ~p"/dashboard"}
      ])

    {:ok, socket}
  end

  def handle_event("update_search_query", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, :search_entries, [])
    {:noreply, socket}
  end

  def handle_event("update_search_query", %{"search" => %{"query" => search_query}}, socket) do
    products = Product.search(search_query)
    socket = assign(socket, :search_entries, products)

    {:noreply, socket}
  end

  def handle_event("click_search_entry", %{"id" => product_id}, socket) do
    product =
      Enum.find(socket.assigns.search_entries, fn item -> item.id == product_id end)

    Wishlist.add_to_wishlist("dd9d433f-0cd9-4a3b-91c4-80cbe94ee67a", product_id)

    updated_products = socket.assigns.products ++ [product]

    socket = assign(socket, :products, updated_products)

    {:noreply, socket}
  end

  def handle_event("add_to_wishlist", %{"name" => name}, socket) do
    updated_wishlists = [%Wishlist.Model{name: name} | socket.assigns.wishlists]

    Wishlist.upsert_wishlist(%{
      id: UUID.uuid4(),
      user_id: "b1c0d3fa-5489-4d13-ab2c-7cc2241fe820",
      name: name
    })

    socket = assign(socket, wishlists: updated_wishlists)

    {:noreply, socket}
  end
end
