-- file: queries.sql
-- name: upsert_wishlist
INSERT INTO
  wishlists (id, user_id, name, inserted_at, updated_at)
VALUES
  (
    :id :: text :: uuid,
    :user_id :: text :: uuid,
    :name,
    now(),
    now()
  ) ON CONFLICT (id) DO
UPDATE
SET
  name = EXCLUDED.name RETURNING id :: text;

-- name: get_with_products
SELECT
  W.id :: text,
  W.user_id,
  W.name,
  W.inserted_at,
  SUM(P.price) OVER (PARTITION BY W.id) AS total_cost,
  P.id AS product_id,
  P.name AS product_name,
  P.category AS product_category,
  P.price AS product_price
FROM
  wishlists W
  LEFT JOIN wishlist_products WP ON WP.wishlist_id = W.id
  LEFT JOIN products P ON P.id = WP.product_id
ORDER BY
  W.inserted_at DESC,
  WP.inserted_at DESC;

-- name: insert_to_wishlist
INSERT INTO
  wishlist_products (wishlist_id, product_id, inserted_at, updated_at)
VALUES
  (
    :wishlist_id :: text :: uuid,
    :product_id :: text :: uuid,
    now(),
    now()
  );

-- name: delete_wishlist
DELETE FROM
  wishlists
WHERE
  id = :wishlist_id :: text :: uuid;