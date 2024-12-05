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
  import SaladUI.Dialog

  def mount(_params, _session, socket) do
    wishlists = Wishlist.get_with_products()

    socket =
      socket
      |> assign(:delete_products_enabled, false)
      |> assign(:search_entries, [])
      |> assign(:wishlists, wishlists)
      |> assign(:current_page, :dashboard)
      |> assign(:breadcrumbs, [
        %{name: "Dashboard", link: ~p"/dashboard"}
      ])

    {:ok, socket}
  end

  def handle_event("add_wishlist_clicked", %{"wishlist_id" => wishlist_id}, socket) do
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

  def handle_event("add_product_to_list", %{"product_id" => product_id}, socket) do
    product = Enum.find(socket.assigns.search_entries, fn item -> item.id == product_id end)

    Wishlist.add_to_wishlist(socket.assigns.selected_wishlist_id, product_id)

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn wishlist ->
        if wishlist.id == socket.assigns.selected_wishlist_id do
          updated_products = [product | wishlist.products]

          %{
            wishlist
            | products: updated_products,
              total_cost:
                Enum.reduce(updated_products, Decimal.new(0), fn product, acc ->
                  Decimal.add(acc, product.price)
                end)
          }
        else
          wishlist
        end
      end)

    products = Product.search(socket.assigns.search_query)

    socket =
      assign(socket,
        wishlists: updated_wishlists,
        search_entries: products,
        delete_products_enabled: false
      )

    {:noreply, socket}
  end

  def handle_event(
        "delete_product_from_list",
        %{"wishlist_id" => wishlist_id, "product_id" => product_id},
        socket
      ) do
    Wishlist.delete_product_from_list(wishlist_id, product_id)

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn wishlist ->
        if wishlist.id == wishlist_id do
          updated_products = Enum.filter(wishlist.products, fn item -> item.id != product_id end)
          # TODO Reduce the total price of the cost also do this in upside method
          %{
            wishlist
            | products: updated_products,
              total_cost:
                Enum.reduce(updated_products, Decimal.new(0), fn product, acc ->
                  Decimal.add(acc, product.price)
                end)
          }
        else
          wishlist
        end
      end)

    socket = assign(socket, wishlists: updated_wishlists)
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

    socket = assign(socket, wishlists: updated_wishlists, delete_products_enabled: false)

    {:noreply, socket}
  end

  def handle_event("delete_wishlist", %{"wishlist_id" => wishlist_id}, socket) do
    updated_wishlist =
      Enum.filter(socket.assigns.wishlists, fn item -> item.id != wishlist_id end)

    Wishlist.delete_wishlist(wishlist_id)
    socket = assign(socket, wishlists: updated_wishlist)

    {:noreply, socket}
  end

  def handle_event("edit_wishlist", params, socket) do
    # Find the key that starts with "wishlist_"
    {"wishlist_" <> wishlist_id, wishlist_params} =
      Enum.find(params, fn {key, _val} -> String.starts_with?(key, "wishlist_") end)

    name = wishlist_params["name"]

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn wishlist ->
        if wishlist.id == wishlist_id do
          %{wishlist | name: name}
        else
          wishlist
        end
      end)

    Wishlist.upsert_wishlist(%{
      id: wishlist_id,
      user_id: "b1c0d3fa-5489-4d13-ab2c-7cc2241fe820",
      name: name
    })

    socket = assign(socket, wishlists: updated_wishlists, delete_products_enabled: false)
    {:noreply, socket}
  end

  def handle_event("toggle_delete_products", %{}, socket) do
    socket = assign(socket, delete_products_enabled: !socket.assigns.delete_products_enabled)

    {:noreply, socket}
  end
end
