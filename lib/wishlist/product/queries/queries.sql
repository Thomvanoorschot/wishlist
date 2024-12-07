-- file: queries.sql
-- name: get_products
SELECT
    id :: text AS id,
    name,
    price,
    category,
    similarity(name, :product_name) l
FROM
    products P
    LEFT JOIN wishlist_products WP ON WP.product_id = P.id
WHERE
    WP.wishlist_id is null
    AND similarity(name, :product_name) > 0.2
ORDER BY
    l DESC
LIMIT
    5;

-- name: insert_product
INSERT INTO
    products (
        id,
        name,
        price,
        description,
        category,
        inserted_at,
        updated_at
    )
VALUES
    (
        :id :: text :: uuid,
        :name,
        :price :: numeric,
        :description,
        :category,
        now(),
        now()
    );