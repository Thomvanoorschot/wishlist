-- file: queries.sql
-- name: insert_store
INSERT INTO
    stores (id, name, inserted_at, updated_at)
VALUES
    (:id :: text :: uuid, :name, now(), now());

-- name: add_product_to_store
INSERT INTO
    products_stores (product_id, store_id, inserted_at, updated_at)
VALUES
    (
        :product_id :: text :: uuid,
        :store_id :: text :: uuid,
        now(),
        now()
    );