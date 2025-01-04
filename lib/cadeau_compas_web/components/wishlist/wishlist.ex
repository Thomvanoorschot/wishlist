defmodule CadeauCompasWeb.Components.WishlistComponent do
  alias CadeauCompas.Wishlist.Models.WishlistModel
  use CadeauCompasWeb, :live_component

  import SaladUI.{Button, Card, Accordion, DropdownMenu, Menu, Dialog, Tooltip}
  import CadeauCompasWeb.Components.SearchModal

  attr :index, :integer, default: 0
  attr :delete_products_enabled, :boolean, default: false
  attr :wishlist, WishlistModel, required: true
  attr :editable, :boolean, default: false
  attr :current_user, :map, required: false, default: nil

  def wishlist(assigns) do
    ~H"""
    <.card class="max-w-4xl mx auto">
      <%= if @editable do %>
        <.accordion_trigger open={@wishlist.products != [] && @index == 0} class="flex flex-row-reverse p-2">
          <.wishlist_header wishlist={@wishlist} editable={@editable} current_user={@current_user} />
        </.accordion_trigger>
        <.accordion_content>
          <.wishlist_content wishlist={@wishlist} editable={@editable} current_user={@current_user} delete_products_enabled={@delete_products_enabled} />
        </.accordion_content>
      <% else %>
        <.wishlist_header wishlist={@wishlist} editable={@editable} />
        <.wishlist_content wishlist={@wishlist} editable={@editable} current_user={@current_user} />
      <% end %>
    </.card>
    """
  end

  attr :wishlist, WishlistModel, required: true
  attr :editable, :boolean, default: false
  attr :current_user, :map, required: false, default: nil

  def wishlist_header(%{editable: false} = assigns) do
    ~H"""
    <.card_header class="w-full pl-2">
      <div class="ml-4">
        <.card_title><%= @wishlist.name %></.card_title>
      </div>
    </.card_header>
    """
  end

  def wishlist_header(assigns) do
    ~H"""
    <.card_header class="w-full pl-2">
      <div class="flex items-center justify-between">
        <div>
          <.card_title><%= @wishlist.name %></.card_title>
          <%= if @wishlist.total_cost  do %>
            <%= if @wishlist.total_cost == @wishlist.initial_total_cost do %>
              <.card_description>€<%= @wishlist.total_cost %></.card_description>
            <% else %>
              <.card_description>€<%= @wishlist.total_cost %> of total €<%= @wishlist.initial_total_cost %></.card_description>
            <% end %>
          <% end %>
        </div>
        <div class="flex gap-2">
          <.tooltip>
            <.button variant="outline" id={"copy-#{@wishlist.id}"} data-to={generatate_detail_page_link(@current_user.username, @wishlist.slug)} phx-hook="Copy">
              <.icon name="hero-link" class="h-5 w-5" />
            </.button>
            <.tooltip_content class="bg-primary text-white">
              <p>Copy URL to clipboard</p>
            </.tooltip_content>
          </.tooltip>
          <.button phx-click={
            JS.set_attribute({"wishlist_id", @wishlist.id}, to: "#selected_wishlist")
            |> open_search_modal()
          }>
            Add item
          </.button>
          <.dropdown_menu>
            <.dropdown_menu_trigger>
              <.button variant="outline">
                <.icon name="hero-ellipsis-vertical" class="h-4 w-4" />
              </.button>
            </.dropdown_menu_trigger>
            <.dropdown_menu_content align="end">
              <.menu class="w-44">
                <.menu_item class="" phx-click={show_modal("edit-dialog-#{@wishlist.id}")} onclick="event.preventDefault(); ">
                  <.icon name="hero-pencil-square" class="mr-2 h-4 w-4" />
                  <span>Edit</span>
                </.menu_item>
                <.menu_item phx-click={show_modal("delete-dialog-#{@wishlist.id}")} onclick="event.preventDefault(); ">
                  <.icon name="hero-trash" class="mr-2 h-4 w-4" />
                  <span>Delete wishlist</span>
                </.menu_item>
                <.menu_item phx-click="toggle_delete_products" onclick="event.preventDefault(); ">
                  <.icon name="hero-minus-circle" class="mr-2 h-4 w-4" />
                  <span>Delete products</span>
                </.menu_item>
                <.menu_item>
                  <a href={generatate_detail_page_link(@current_user.username, @wishlist.slug)} target="_blank" rel="noopener noreferrer">
                    <.icon name="hero-arrow-top-right-on-square" class="mr-2 h-4 w-4" />
                    <span>Open detail page</span>
                  </a>
                </.menu_item>
              </.menu>
            </.dropdown_menu_content>
          </.dropdown_menu>
        </div>
      </div>
    </.card_header>
    """
  end

  attr :wishlist, WishlistModel, required: true
  attr :delete_products_enabled, :boolean, default: false
  attr :editable, :boolean, default: false
  attr :current_user, :map, required: false

  def wishlist_content(%{editable: false} = assigns) do
    ~H"""
    <.card_content>
      <div class="space-y-8">
        <%= for product <- @wishlist.products do %>
          <div class="flex items-center">
            <span class="relative flex shrink-0 overflow-hidden rounded-full h-9 w-9">
              <img class="aspect-square h-full w-full" alt={product.name} src="https://placehold.co/80" />
            </span>
            <div class="ml-4 space-y-1">
              <p class={"text-sm font-medium leading-none #{if product.checked_off_by != nil and (assigns[:current_user] == nil or product.checked_off_by != @current_user.id ) do "line-through" end }"}>
                <%= product.name %>
              </p>
              <p class={"text-sm text-muted-foreground #{if product.checked_off_by != nil and  (assigns[:current_user] == nil or product.checked_off_by != @current_user.id ) do "line-through" end }"}>
                €<%= product.price %>
              </p>
            </div>
            <.button
              class="ml-auto"
              phx-click="check_off_from_list"
              phx-value-wishlist_id={@wishlist.id}
              phx-value-product_id={product.id}
              phx-disable-with="Submitting..."
              disabled={product.checked_off_by != nil and (assigns[:current_user] == nil or product.checked_off_by != @current_user.id)}
            >
              Check off
            </.button>
          </div>
        <% end %>
      </div>
    </.card_content>
    """
  end

  def wishlist_content(assigns) do
    ~H"""
    <.card_content>
      <div class="space-y-8">
        <%= for product <- @wishlist.products do %>
          <div class="flex items-center">
            <span class="relative flex shrink-0 overflow-hidden rounded-full h-9 w-9">
              <img class="aspect-square h-full w-full" alt={product.name} src="https://placehold.co/80" />
            </span>
            <div class="ml-4 space-y-1">
              <p class={"text-sm font-medium leading-none #{if product.checked_off_by != nil do "line-through" end }"}><%= product.name %></p>
              <p class={"text-sm text-muted-foreground #{if product.checked_off_by != nil do "line-through" end }"}>€<%= product.price %></p>
            </div>
            <%= if @delete_products_enabled do %>
              <div phx-click="delete_product_from_list" phx-value-wishlist_id={@wishlist.id} phx-value-product_id={product.id} class="ml-auto">
                <.icon name="hero-minus-circle-solid" class="7 bg-destructive hover:opacity-60" />
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </.card_content>
    """
  end

  defp generatate_detail_page_link(username, slug) do
    "https://localhost:4001/wishlist/#{username}/#{slug}"
  end
end
