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
  import SaladUI.DropdownMenu
  import SaladUI.Menu
  import SaladUI.AlertDialog
  import SaladUI.Dialog

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

  @spec handle_event(<<_::64, _::_*8>>, map(), any()) :: {:noreply, any()}
  def handle_event("add_wishlist_clicked", %{"wishlist_id" => wishlist_id}, socket) do
    IO.inspect(wishlist_id)
    socket = assign(socket, :selected_wishlist_id, wishlist_id)
    {:noreply, socket}
  end

  def handle_event("update_search_query", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, search_entries: [], search_query: "")
    {:noreply, socket}
  end

  def handle_event("update_search_query", %{"search" => %{"query" => search_query}}, socket) do
    products = Product.search(search_query)
    socket = assign(socket, search_entries: products, search_query: search_query)

    {:noreply, socket}
  end

  def handle_event("click_search_entry", %{"id" => product_id}, socket) do
    product = Enum.find(socket.assigns.search_entries, fn item -> item.id == product_id end)

    Wishlist.add_to_wishlist(socket.assigns.selected_wishlist_id, product_id)

    IO.inspect(product.price)

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn wishlist ->
        if wishlist.id == socket.assigns.selected_wishlist_id do
          updated_products = [product | wishlist.products]
          %{wishlist | products: updated_products}

          %{
            wishlist
            | products: updated_products,
              total_cost:
                (wishlist.total_cost ||
                   Decimal.new(0))
                |> Decimal.add(product.price)
          }
        else
          wishlist
        end
      end)

    products = Product.search(socket.assigns.search_query)
    socket = assign(socket, wishlists: updated_wishlists, search_entries: products)

    {:noreply, socket}
  end

  def handle_event("create_wishlist", %{"name" => name}, socket) do
    new_id = UUID.uuid4()
    updated_wishlists = [%Wishlist.Model{id: new_id, name: name} | socket.assigns.wishlists]

    Wishlist.upsert_wishlist(%{
      id: new_id,
      user_id: "b1c0d3fa-5489-4d13-ab2c-7cc2241fe820",
      name: name
    })

    socket = assign(socket, wishlists: updated_wishlists)

    {:noreply, socket}
  end

  def handle_event("delete_wishlist", %{"wishlist_id" => wishlist_id}, socket) do
    updated_wishlist =
      Enum.filter(socket.assigns.wishlists, fn item -> item.id != wishlist_id end)

    socket = assign(socket, wishlists: updated_wishlist)

    {:noreply, socket}
  end
end
