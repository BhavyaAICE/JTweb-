/*
  # Create Missing Tables for Admin Panel
  
  1. New Tables
    - `orders` - Store customer orders
      - `id` (uuid, primary key)
      - `order_number` (text, unique)
      - `customer_email` (text)
      - `product_id` (uuid, foreign key to products)
      - `amount` (numeric)
      - `status` (text) - pending or completed
      - `created_at` (timestamptz)
      
    - `reviews` - Store customer reviews
      - `id` (uuid, primary key)
      - `author` (text)
      - `rating` (integer) - 1 to 5
      - `comment` (text)
      - `created_at` (timestamptz)
      
    - `site_settings` - Store customizable site settings
      - `id` (uuid, primary key)
      - `key` (text, unique)
      - `value` (text)
      - `updated_at` (timestamptz)
  
  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated admin users
    - Add public read policies where appropriate
*/

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number text UNIQUE NOT NULL,
  customer_email text NOT NULL,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  amount numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view orders"
  ON orders
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert orders"
  ON orders
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

CREATE POLICY "Admins can update orders"
  ON orders
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete orders"
  ON orders
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author text NOT NULL,
  rating integer NOT NULL DEFAULT 5,
  comment text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews"
  ON reviews
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert reviews"
  ON reviews
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete reviews"
  ON reviews
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Create site_settings table
CREATE TABLE IF NOT EXISTS site_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value text NOT NULL DEFAULT '',
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view site settings"
  ON site_settings
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can update site settings"
  ON site_settings
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );

-- Insert default site settings
INSERT INTO site_settings (key, value) VALUES
  ('hero_image', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1920&h=600&fit=crop'),
  ('discord_link', 'https://discord.gg/auroraaccounts'),
  ('hero_heading', 'Unlock Premium Digital Services with AuroraServices'),
  ('hero_subheading', 'Your trusted platform for high-quality digital assets, game services, premium accounts, tools, and exclusive solutions.'),
  ('hero_paragraph', 'AuroraServices is a leading online provider of secure, fast, and premium digital services.')
ON CONFLICT (key) DO NOTHING;

-- Insert sample reviews
INSERT INTO reviews (author, rating, comment) VALUES
  ('Alex M.', 5, 'Amazing service! Fast delivery and great quality products.'),
  ('Sarah K.', 5, 'Best experience ever. Highly recommend!'),
  ('Mike R.', 4, 'Good service, will definitely buy again.'),
  ('Emma L.', 5, 'Excellent customer support and premium products.')
ON CONFLICT DO NOTHING;

-- Update products policies to allow public viewing
DROP POLICY IF EXISTS "Anyone can view products" ON products;
CREATE POLICY "Anyone can view products"
  ON products
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Update product_variants policies to allow public viewing
DROP POLICY IF EXISTS "Anyone can view product variants" ON product_variants;
CREATE POLICY "Anyone can view product variants"
  ON product_variants
  FOR SELECT
  TO anon, authenticated
  USING (true);
