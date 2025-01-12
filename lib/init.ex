defmodule MyDreamGifts.Init do
  alias MyDreamGifts.Store
  alias MyDreamGifts.Product

  def seed() do
    # Generate a UUID for the store
    store_id = Ecto.UUID.generate()

    # Insert the store using AyeSQL
    store_name = "SuperMart"
    Store.Queries.Q.insert_store(id: store_id, name: store_name)

    # Define product categories
    categories = [
      "Electronics",
      "Home Appliances",
      "Furniture",
      "Clothing",
      "Books",
      "Toys",
      "Sports Equipment",
      "Beauty Products",
      "Groceries",
      "Automotive"
    ]

    # Generate and insert 100 products
    for _ <- 1..10000 do
      product_id = Ecto.UUID.generate()
      category = Enum.random(categories)
      product_name = Faker.Commerce.product_name()
      price = Float.round(:rand.uniform() * 1000, 2)
      description = Faker.Lorem.sentence()

      # Insert product using AyeSQL
      Product.Queries.Q.insert_product(
        id: product_id,
        name: product_name,
        price: price,
        description: description,
        category: category
      )

      # Associate product with store
      Store.Queries.Q.add_product_to_store(
        product_id: product_id,
        store_id: store_id
      )
    end
  end
end
