/*
  # Add SellAuth Variant ID to Products Table

  1. Changes
    - Add `sellauth_variant_id` column to products table for standalone products without variants
    - This allows products to specify a specific SellAuth variant option

  2. Details
    - Column: `sellauth_variant_id` (text, nullable)
    - Used for non-variant products to link to a specific variant in SellAuth
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'products' AND column_name = 'sellauth_variant_id'
  ) THEN
    ALTER TABLE products ADD COLUMN sellauth_variant_id text;
  END IF;
END $$;
