/*
  # Add SellAuth Variant ID Column

  1. Changes
    - Add `sellauth_variant_id` column to `product_variants` table
    - This stores the numeric variant ID from SellAuth (separate from product ID)
  
  2. Notes
    - SellAuth requires both productId and variantId for checkout
    - Existing `sellauth_product_id` will store the main product ID
    - New `sellauth_variant_id` will store the specific variant ID
*/

-- Add sellauth_variant_id column to product_variants if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'product_variants' AND column_name = 'sellauth_variant_id'
  ) THEN
    ALTER TABLE product_variants ADD COLUMN sellauth_variant_id text;
  END IF;
END $$;
