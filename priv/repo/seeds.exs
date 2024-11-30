# priv/repo/seeds.exs

alias Wishlist.Repo
alias Wishlist.DbSchema.{Store, Product, ProductsStore}

# Ensure UUID generation is available
store_id = Ecto.UUID.generate()

# Insert a single store
store = %Store{
  id: store_id,
  name: "SuperMart"
}

Repo.insert!(store)

# Define realistic product categories
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
for _ <- 1..100 do
  product_id = Ecto.UUID.generate()

  # Randomly pick a category
  category = Enum.random(categories)

  # Generate a realistic product name
  product_name = Faker.Commerce.product_name()

  # Insert product
  product = %Product{
    id: product_id,
    name: product_name,
    # Random price between 0.01 and 1000
    price: Decimal.new(:rand.uniform(1000)) |> Decimal.round(2),
    description: Faker.Lorem.sentence(),
    category: category
  }

  Repo.insert!(product)

  # Associate product with store
  product_store = %ProductsStore{
    product_id: product_id,
    store_id: store_id
  }

  Repo.insert!(product_store)
end

IO.puts("Inserted 1 store and 100 products.")
