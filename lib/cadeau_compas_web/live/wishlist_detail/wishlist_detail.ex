defmodule CadeauCompasWeb.Live.WishlistDetail do
  alias CadeauCompas.Product.Models.ProductModel
  use CadeauCompasWeb, :live_view

  import LiveToast
  import SaladUI.{Button, Input, Form}
  import CadeauCompasWeb.Components.{WishlistComponent, CustomDialog}
  alias CadeauCompas.{Wishlist}

  def mount(%{"username" => owner_username, "wishlist_slug" => slug}, _session, socket) do
    socket =
      socket
      |> assign(:current_page, :wishlist_detail)

    case Wishlist.get_detail_with_products(owner_username, slug, socket.assigns.current_user.id) do
      {:ok, wishlist} ->
        {:ok,
         socket
         |> assign(:wishlist, wishlist)}

      {:ask_permission, wishlist_id, secret_question} ->
        ask_permission_form = to_form(%{"secret_answer" => ""}, as: "ask_permission_form")

        {:ok,
         socket
         |> assign(%{
           error: :ask_permission,
           secret_question: secret_question,
           ask_permission_form: ask_permission_form,
           ask_permission_form_error: nil,
           wishlist_id: wishlist_id,
           owner_username: owner_username,
           slug: slug
         })}

      {:no_access, wishlist_id} ->
        {:ok, socket |> assign(%{error: :no_access, wishlist_id: wishlist_id})}

      _ ->
        {:ok, socket}
    end
  end

  def handle_event("check_off_from_list", %{"product_id" => product_id}, socket) do
    %{current_user: current_user, wishlist: wishlist} = socket.assigns

    case Wishlist.check_off_from_list(wishlist, product_id, current_user.id) do
      {:ok, updated_wishlist} ->
        {:noreply,
         socket
         |> assign(:wishlist, updated_wishlist)
         |> put_toast(:info, "Checked off!")}

      {:error, err} ->
        {:noreply,
         socket
         |> put_toast(:error, err)}
    end
  end

  def handle_event("ask_permission", %{"ask_permission_form" => %{"secret_answer" => secret_answer}}, socket) do
    %{current_user: current_user, wishlist_id: wishlist_id, owner_username: owner_username, slug: slug} = socket.assigns

    with {:ok} <- Wishlist.answer_secret_question(wishlist_id, secret_answer, current_user.id),
         {:ok, wishlist} <- Wishlist.get_detail_with_products(owner_username, slug, current_user.id) do
      {:noreply,
       socket
       |> put_toast(:info, "That's right!")
       |> assign(%{error: nil, wishlist: wishlist})}
    else
      {:error, err} ->
        {:noreply,
         socket
         |> put_toast(:error, err)}
    end
  end
end
