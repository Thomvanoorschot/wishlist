defmodule CadeauCompas.Wishlist do
  import CadeauCompas.Helpers.StringHelpers
  alias CadeauCompas.Wishlist.Queries
  alias CadeauCompas.Wishlist.Queries.Q
  alias CadeauCompas.Wishlist.Models.WishlistModel
  alias CadeauCompas.Product
  alias CadeauCompas.Product.Models.ProductModel

  def upsert_wishlist(%WishlistModel{id: nil} = wishlist) do
    upsert_wishlist(%WishlistModel{wishlist | id: Ecto.UUID.generate()})
  end

  def upsert_wishlist(%WishlistModel{id: id, user_id: user_id, name: name} = wishlist) do
    case Q.upsert_wishlist(id: id, user_id: user_id, name: name, slug: slugify(name)) do
      {:ok, [%{id: wishlist_id}]} ->
        {:ok, %{wishlist | id: wishlist_id}}

      {:error, _} = error ->
        error
    end
  end

  def get_with_products(user_id) do
    {_, wishlists_dto} = Q.get_with_products([user_id: user_id], into: %Queries.WishlistDTO{})

    WishlistModel.list_from_dto(wishlists_dto)
  end

  def add_to_wishlist_and_update_query(%WishlistModel{id: wishlist_id, products: wishlist_products, user_id: user_id} = wishlist, product_id, query) do
    params = [wishlist_id: wishlist_id, product_id: product_id, user_id: user_id]

    case Q.insert_to_wishlist(params, into: %ProductModel{}) do
      {:ok, inserted_product} ->
        updated_products = inserted_product ++ wishlist_products
        products = Product.search(query)
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}, products}

      {:error, _} = error ->
        error
    end
  end

  def delete_wishlist(wishlist_id, user_id) do
    Q.delete_wishlist(wishlist_id: wishlist_id, user_id: user_id)
  end

  def delete_product_from_list(%WishlistModel{products: products, user_id: user_id} = wishlist, product_id) do
    case Q.delete_product_from_list(wishlist_id: wishlist.id, product_id: product_id, user_id: user_id) do
      {:ok, []} ->
        updated_products = Enum.reject(products, &(&1.id == product_id))
        updated_total_cost = Enum.reduce(updated_products, Decimal.new(0), &Decimal.add(&2, &1.price))
        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost}}

      {:error, []} ->
        {:error, wishlist}
    end
  end

  def get_detail_with_products(owner_username, slug, user_id) do
    with {_, [first | _rest] = dtos} <- Q.get_detail_by_slug_with_products([owner_username: owner_username, slug: slug, user_id: user_id], into: %Queries.WishlistDTO{}) do
      case first do
        %{user_has_access: true} ->
          {:ok, WishlistModel.from_dto(dtos)}

        %{id: id, user_has_access: false, accessibility: "permissioned", secret_question: secret_question} ->
          {:ask_permission, id, secret_question}

        %{id: id, accessibility: "noone"} ->
          {:no_access, id}
      end
    end
  end

  def check_off_from_list(wishlist_id, product_id, user_id) do
    case Q.check_off_from_list(user_id: user_id, product_id: product_id, wishlist_id: wishlist_id) do
      {:ok, [_first | _rest]} ->
        {:ok}

      {:ok, []} ->
        {:error, "Could not check off from list"}

      {:error, err} ->
        {:error, err}
    end
  end

  def answer_secret_question(wishlist_id, secret_answer) do
    case Q.answer_secret_question(wishlist_id: wishlist_id, user_id: "TODO", secret_answer: secret_answer) do
      {:ok, [_first | _rest]} ->
        {:ok}

      {:ok, []} ->
        {:error, "Wrong answer"}

      {:error, err} ->
        {:error, err}
    end
  end
end
