/*
  # Add Sellix Integration Fields to Orders Table

  1. Changes
    - Add `sellix_order_id` column to store Sellix order ID
    - Add `payment_gateway` column to store payment method used
    - Add index on `sellix_order_id` for faster lookups
    - Make `product_id` nullable to support Sellix product mapping

  2. Notes
    - Existing data is preserved
    - Indexes improve query performance for webhook processing
*/

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'sellix_order_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN sellix_order_id text;
    CREATE INDEX IF NOT EXISTS idx_orders_sellix_order_id ON orders(sellix_order_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'payment_gateway'
  ) THEN
    ALTER TABLE orders ADD COLUMN payment_gateway text;
  END IF;
END $$;
