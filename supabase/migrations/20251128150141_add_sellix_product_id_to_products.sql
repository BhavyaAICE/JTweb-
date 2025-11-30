/*
  # Add Sellix Product ID to Products Table

  1. Changes
    - Add `sellix_product_id` column to store Sellix product identifier
    - This allows mapping between AuroraServices products and Sellix products
    - Add index for faster lookups

  2. Notes
    - Field is optional to support gradual migration
    - Products without Sellix ID will show configuration message
*/

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'products' AND column_name = 'sellix_product_id'
  ) THEN
    ALTER TABLE products ADD COLUMN sellix_product_id text;
    CREATE INDEX IF NOT EXISTS idx_products_sellix_id ON products(sellix_product_id);
  END IF;
END $$;
