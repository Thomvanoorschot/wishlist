defmodule MyDreamGifts.Wishlist do
  import MyDreamGifts.Helpers.StringHelpers
  alias MyDreamGifts.Wishlist.Queries
  alias MyDreamGifts.Wishlist.Queries.Q
  alias MyDreamGifts.Wishlist.Models.WishlistModel
  alias MyDreamGifts.Product
  alias MyDreamGifts.Product.Models.ProductModel

  def upsert_wishlist(%WishlistModel{id: nil} = wishlist) do
    upsert_wishlist(%WishlistModel{wishlist | id: Ecto.UUID.generate()})
  end

  def upsert_wishlist(
        %WishlistModel{
          id: id,
          user_id: user_id,
          name: name,
          accessibility: accessibility,
          secret_question: secret_question,
          secret_answer: secret_answer
        } = wishlist
      ) do
    new_accessibility = accessibility || "noone"
    slug = slugify(name)

    case Q.upsert_wishlist(
           id: id,
           user_id: user_id,
           name: name,
           slug: slug,
           accessibility: new_accessibility,
           secret_question: secret_question,
           secret_answer: secret_answer
         ) do
      {:ok, [%{id: wishlist_id}]} ->
        {:ok,
         %{
           wishlist
           | id: wishlist_id,
             user_id: user_id,
             name: name,
             slug: slug,
             accessibility: new_accessibility
         }}

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
        {updated_total_cost, updated_initial_total_cost} = calculate_total_cost(updated_products)

        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost, initial_total_cost: updated_initial_total_cost}, products}

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
        {updated_total_cost, updated_initial_total_cost} = calculate_total_cost(updated_products)

        {:ok, %{wishlist | products: updated_products, total_cost: updated_total_cost, initial_total_cost: updated_initial_total_cost}}

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

  def check_off_from_list(%WishlistModel{id: id} = wishlist, product_id, user_id) do
    case Q.check_off_from_list(user_id: user_id, product_id: product_id, wishlist_id: id) do
      {:ok, [_first | _rest]} ->
        updated_products =
          Enum.map(wishlist.products, fn
            %ProductModel{id: ^product_id} = p -> %ProductModel{p | checked_off_by: user_id}
            p -> p
          end)

        {:ok, %WishlistModel{wishlist | products: updated_products}}

      {:ok, []} ->
        {:error, "Could not check off from list"}

      {:error, err} ->
        {:error, err}
    end
  end

  def undo_check_off_from_list(%WishlistModel{id: id} = wishlist, product_id, user_id) do
    case Q.undo_check_off_from_list(user_id: user_id, product_id: product_id, wishlist_id: id) do
      {:ok, [_first | _rest]} ->
        updated_products =
          Enum.map(wishlist.products, fn
            %ProductModel{id: ^product_id} = p -> %ProductModel{p | checked_off_by: nil}
            p -> p
          end)

        {:ok, %WishlistModel{wishlist | products: updated_products}}

      {:ok, []} ->
        {:error, "Could not check off from list"}

      {:error, err} ->
        {:error, err}
    end
  end

  def answer_secret_question(wishlist_id, secret_answer, user_id) do
    case Q.answer_secret_question(wishlist_id: wishlist_id, user_id: user_id, secret_answer: secret_answer) do
      {:ok, [_first | _rest]} ->
        {:ok}

      {:ok, []} ->
        {:error, "Wrong answer"}

      {:error, err} ->
        {:error, err}
    end
  end

  defp calculate_total_cost(products) do
    Enum.reduce(products, {Decimal.new(0), Decimal.new(0)}, fn
      %ProductModel{checked_off_by: nil, price: price}, {total_cost, initial_total_cost} ->
        {
          Decimal.add(total_cost, price),
          Decimal.add(initial_total_cost, price)
        }

      %ProductModel{price: price}, {total_cost, initial_total_cost} ->
        {
          total_cost,
          Decimal.add(initial_total_cost, price)
        }
    end)
  end
end
