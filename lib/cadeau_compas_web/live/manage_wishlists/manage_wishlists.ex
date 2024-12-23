defmodule CadeauCompasWeb.Live.ManageWishlists do
  use CadeauCompasWeb, :live_view

  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Wishlist

  import CadeauCompasWeb.Components.SearchModal
  import SaladUI.{Button, Card, Accordion, Input, Form, DropdownMenu, Menu, Dialog}

  def mount(_params, _session, socket) do
    %{id: user_id} = socket.assigns.current_user
    wishlists = Wishlist.get_with_products(user_id)

    socket =
      socket
      |> assign(:delete_products_enabled, false)
      |> assign(:search_entries, [])
      |> assign(:wishlists, wishlists)
      |> assign(:current_page, :manage_wishlists)
      |> assign(:breadcrumbs, [
        %{name: "Wishlists", link: ~p"/users/reigster"}
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
    with %WishlistModel{} = wishlist <- Enum.find(socket.assigns.wishlists, &(&1.id == wishlist_id)),
         {:ok, updated_wishlist, products} <-
           Wishlist.add_to_wishlist_and_update_query(wishlist, product_id, socket.assigns.search_query) do
      updated_wishlists =
        Enum.map(socket.assigns.wishlists, fn
          %WishlistModel{id: ^wishlist_id} -> updated_wishlist
          wishlist -> wishlist
        end)

      {:noreply,
       assign(socket,
         wishlists: updated_wishlists,
         search_entries: products,
         delete_products_enabled: false
       )}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("delete_product_from_list", %{"wishlist_id" => wishlist_id, "product_id" => product_id}, socket) do
    %{id: user_id} = socket.assigns.current_user

    with %WishlistModel{} = wishlist <- Enum.find(socket.assigns.wishlists, &(&1.id == wishlist_id)),
         {:ok, updated_wishlist} <- Wishlist.delete_product_from_list(%WishlistModel{wishlist | user_id: user_id}, product_id) do
      updated_wishlists =
        Enum.map(socket.assigns.wishlists, fn
          %WishlistModel{id: ^wishlist_id} -> updated_wishlist
          wishlist -> wishlist
        end)

      {:noreply, assign(socket, wishlists: updated_wishlists)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("create_wishlist", %{"name" => name}, socket) do
    %{id: user_id} = socket.assigns.current_user

    case Wishlist.upsert_wishlist(%WishlistModel{
           user_id: user_id,
           name: name
         }) do
      {:ok, wishlist} ->
        updated_wishlists = [wishlist | socket.assigns.wishlists]

        {:noreply,
         assign(socket,
           wishlists: updated_wishlists,
           delete_products_enabled: false
         )}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("delete_wishlist", %{"wishlist_id" => wishlist_id}, socket) do
    %{id: user_id} = socket.assigns.current_user

    with {:ok, _} <- Wishlist.delete_wishlist(wishlist_id, user_id) do
      updated_wishlists = Enum.reject(socket.assigns.wishlists, &(&1.id == wishlist_id))
      {:noreply, assign(socket, wishlists: updated_wishlists)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("edit_wishlist", %{"name" => name, "wishlist_id" => wishlist_id}, socket) do
    with %WishlistModel{} = wishlist <- Enum.find(socket.assigns.wishlists, &(&1.id == wishlist_id)),
         {:ok, updated_wishlist} <- Wishlist.upsert_wishlist(%{wishlist | name: name}) do
      updated_wishlists =
        Enum.map(socket.assigns.wishlists, fn
          %WishlistModel{id: ^wishlist_id} -> updated_wishlist
          wishlist -> wishlist
        end)

      {:noreply, assign(socket, wishlists: updated_wishlists, delete_products_enabled: false)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_delete_products", %{}, socket) do
    socket = assign(socket, delete_products_enabled: !socket.assigns.delete_products_enabled)

    {:noreply, socket}
  end
end
