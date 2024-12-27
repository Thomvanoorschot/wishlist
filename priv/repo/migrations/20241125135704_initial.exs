defmodule CadeauCompas.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    create table(:stores, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      timestamps(type: :timestamptz)
    end

    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :category, :string, null: false
      add :price, :decimal, null: false, precision: 10, scale: 2
      add :description, :text

      timestamps(type: :timestamptz)
    end

    create index(:products, ["name gin_trgm_ops"], using: :gin)

    create table(:products_stores, primary_key: false) do
      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      add :store_id, references(:stores, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:products_stores, [:product_id, :store_id])

    create table(:wishlists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :binary_id, null: false
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:wishlists, [:user_id, :slug])

    create table(:wishlist_products, primary_key: false) do
      add :wishlist_id,
          references(:wishlists, type: :binary_id, on_delete: :delete_all),
          null: false

      add :product_id,
          references(:products, type: :binary_id, on_delete: :delete_all),
          null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:wishlist_products, [:wishlist_id, :product_id])
  end
end
