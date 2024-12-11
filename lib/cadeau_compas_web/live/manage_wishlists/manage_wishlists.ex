defmodule CadeauCompasWeb.Live.ManageWishlists do
  use CadeauCompasWeb, :live_view

  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Wishlist

  import CadeauCompasWeb.Components.SearchModal
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
      |> assign(:current_page, :manage_wishlists)
      |> assign(:breadcrumbs, [
        %{name: "Wishlists", link: ~p"/wishlist/manage"}
      ])

    {:ok, socket}
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

  def handle_event("add_product_to_list", %{"product_id" => product_id, "wishlist_id" => wishlist_id}, socket) do
    wishlist = Enum.find(socket.assigns.wishlists, fn wishlist -> wishlist.id == wishlist_id end)

    {:ok, updated_wishlist, products} =
      Wishlist.add_to_wishlist_and_update_query(
        wishlist,
        product_id,
        socket.assigns.search_query
      )

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn
        %WishlistModel{id: ^wishlist_id} -> updated_wishlist
        wishlist -> wishlist
      end)

    socket =
      assign(socket,
        wishlists: updated_wishlists,
        search_entries: products,
        delete_products_enabled: false
      )

    {:noreply, socket}
  end

  def handle_event("delete_product_from_list", %{"wishlist_id" => wishlist_id, "product_id" => product_id}, socket) do
    wishlist = Enum.find(socket.assigns.wishlists, fn wishlist -> wishlist.id == wishlist_id end)

    {:ok, updated_wishlist} = Wishlist.delete_product_from_list(wishlist, product_id)

    updated_wishlists =
      Enum.map(socket.assigns.wishlists, fn
        %WishlistModel{id: ^wishlist_id} -> updated_wishlist
        wishlist -> wishlist
      end)

    socket = assign(socket, wishlists: updated_wishlists)
    {:noreply, socket}
  end

  def handle_event("create_wishlist", %{"name" => name}, socket) do
    case Wishlist.upsert_wishlist(%WishlistModel{user_id: "b1c0d3fa-5489-4d13-ab2c-7cc2241fe820", name: name}) do
      {:ok, wishlist} ->
        updated_wishlists = [
          wishlist | socket.assigns.wishlists
        ]

        socket = assign(socket, wishlists: updated_wishlists, delete_products_enabled: false)
        {:noreply, socket}
    end
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
