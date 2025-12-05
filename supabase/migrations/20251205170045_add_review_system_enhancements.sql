/*
  # Review System Enhancements

  1. Changes to Reviews Table
    - Add `user_id` column to link reviews to users
    - Add `product_id` column to link reviews to products
    - Add `verified_purchase` column to mark reviews from actual buyers
    - Add `helpful_count` column for future feature (upvotes)

  2. Security
    - Update RLS policies to allow authenticated users to insert their own reviews
    - Users can only edit/delete their own reviews
    - Anyone can read reviews

  3. Notes
    - Existing reviews will have NULL user_id (anonymous reviews)
    - Verified purchases will be checked against orders table
*/

-- Add new columns to reviews table if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'reviews' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE reviews ADD COLUMN user_id uuid REFERENCES auth.users(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'reviews' AND column_name = 'product_id'
  ) THEN
    ALTER TABLE reviews ADD COLUMN product_id uuid REFERENCES products(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'reviews' AND column_name = 'verified_purchase'
  ) THEN
    ALTER TABLE reviews ADD COLUMN verified_purchase boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'reviews' AND column_name = 'helpful_count'
  ) THEN
    ALTER TABLE reviews ADD COLUMN helpful_count integer DEFAULT 0;
  END IF;
END $$;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_verified_purchase ON reviews(verified_purchase);

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Anyone can read reviews" ON reviews;
DROP POLICY IF EXISTS "Authenticated users can insert reviews" ON reviews;
DROP POLICY IF EXISTS "Users can update own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can delete own reviews" ON reviews;

-- Create RLS policies for reviews
CREATE POLICY "Anyone can read reviews"
  ON reviews
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert reviews"
  ON reviews
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
  ON reviews
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
  ON reviews
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create a function to check if user made a verified purchase
CREATE OR REPLACE FUNCTION check_verified_purchase(p_user_id uuid, p_product_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM orders o
    INNER JOIN users u ON u.email = o.customer_email
    WHERE u.id = p_user_id 
    AND o.product_id = p_product_id 
    AND o.status = 'completed'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a function to get site statistics
CREATE OR REPLACE FUNCTION get_site_stats()
RETURNS json AS $$
DECLARE
  total_products integer;
  total_customers integer;
  total_orders integer;
  avg_rating numeric;
  total_reviews integer;
BEGIN
  SELECT COUNT(*) INTO total_products FROM products;
  
  SELECT COUNT(DISTINCT customer_email) INTO total_customers FROM orders WHERE status = 'completed';
  
  SELECT COUNT(*) INTO total_orders FROM orders WHERE status = 'completed';
  
  SELECT COALESCE(AVG(rating), 0) INTO avg_rating FROM reviews;
  
  SELECT COUNT(*) INTO total_reviews FROM reviews;
  
  RETURN json_build_object(
    'total_products', COALESCE(total_products, 0),
    'total_customers', COALESCE(total_customers, 0),
    'total_orders', COALESCE(total_orders, 0),
    'avg_rating', ROUND(COALESCE(avg_rating, 0), 1),
    'total_reviews', COALESCE(total_reviews, 0)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
