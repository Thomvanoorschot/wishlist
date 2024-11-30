-- file: product_queries.sql
-- name: get_products
SELECT id::text AS id, name, price, category, similarity( name, :product_name) l
FROM products 
WHERE similarity( name, :product_name) > 0.2
ORDER BY l DESC
LIMIT 5;