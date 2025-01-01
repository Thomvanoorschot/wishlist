defmodule CadeauCompasWeb.Live.WishlistDetail do
  alias CadeauCompas.Product.Models.ProductModel
  use CadeauCompasWeb, :live_view

  import LiveToast
  import SaladUI.{Button, Input, Form}
  import CadeauCompasWeb.Components.{WishlistComponent, CustomDialog}
  alias CadeauCompas.{Wishlist}

  def mount(%{"username" => owner_username, "wishlist_slug" => slug}, _session, socket) do
    # FIX if user is not logged in check if they have access otherwise prompt for access
    # %{id: user_id} = socket.assigns.current_user
    socket =
      socket
      |> assign(:current_page, :wishlist_detail)

    case Wishlist.get_detail_with_products(owner_username, slug, "TODO") do
      {:ok, wishlist} ->
        {:ok, socket |> assign(:wishlist, wishlist)}

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

  def handle_event("check_off_from_list", %{"wishlist_id" => wishlist_id, "product_id" => product_id}, socket) do
    %{id: user_id} = socket.assigns.current_user

    case Wishlist.check_off_from_list(wishlist_id, product_id, "TODO") do
      {:ok} ->
        updated_products =
          Enum.map(socket.assigns.wishlist.products, fn
            %ProductModel{id: ^product_id} = p -> %ProductModel{p | is_checked_off: true}
            p -> p
          end)

        {:noreply,
         socket
         |> assign(:wishlist, %{socket.assigns.wishlist | products: updated_products})
         |> put_toast(:info, "Checked off!")}

      {:error, err} ->
        {:noreply,
         socket
         |> put_toast(:error, err)}
    end
  end

  def handle_event("ask_permission", %{"ask_permission_form" => %{"secret_answer" => secret_answer}}, socket) do
    with {:ok} <- Wishlist.answer_secret_question(socket.assigns.wishlist_id, secret_answer),
         {:ok, wishlist} <- Wishlist.get_detail_with_products(socket.assigns.owner_username, socket.assigns.slug, "TODO") do
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
