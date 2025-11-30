/*
  # Migrate from Sellix to SellAuth

  1. Changes
    - Replace sellix_product_id with sellauth_product_id in products table
    - Replace sellix_order_id with sellauth_order_id in orders table
    - Update payment_gateway field to store payment method from SellAuth

  2. New Tables
    - None required - using existing products and orders tables

  3. Modified Columns
    - products: sellix_product_id -> sellauth_product_id
    - orders: sellix_order_id -> sellauth_order_id

  4. Notes
    - Safely handles column renaming with IF EXISTS checks
    - Maintains data integrity throughout migration
    - Indexes updated for new column names
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'products' AND column_name = 'sellix_product_id'
  ) THEN
    ALTER TABLE products RENAME COLUMN sellix_product_id TO sellauth_product_id;
    DROP INDEX IF EXISTS idx_products_sellix_id;
    CREATE INDEX idx_products_sellauth_id ON products(sellauth_product_id);
  ELSIF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'products' AND column_name = 'sellauth_product_id'
  ) THEN
    ALTER TABLE products ADD COLUMN sellauth_product_id text;
    CREATE INDEX idx_products_sellauth_id ON products(sellauth_product_id);
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'sellix_order_id'
  ) THEN
    ALTER TABLE orders RENAME COLUMN sellix_order_id TO sellauth_order_id;
    DROP INDEX IF EXISTS idx_orders_sellix_id;
    CREATE INDEX IF NOT EXISTS idx_orders_sellauth_id ON orders(sellauth_order_id);
  ELSIF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'sellauth_order_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN sellauth_order_id text;
    CREATE INDEX IF NOT EXISTS idx_orders_sellauth_id ON orders(sellauth_order_id);
  END IF;
END $$;
