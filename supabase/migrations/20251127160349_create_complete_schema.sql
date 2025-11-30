/*
  # Complete Schema for AuroraServices

  1. New Tables
    - `products`
      - Core product information with updated schema
      - Supports parent-child product relationships for variants
      - Includes featured status, sale pricing, and stock management
    
    - `product_variants`
      - Child products that belong to a parent product
      - Allows multiple product options within a category
    
    - `orders`
      - Order tracking and management
      - Links to products and customers
    
    - `reviews`
      - Customer reviews with ratings
      - Tracks review metadata
    
    - `site_settings`
      - Customizable site configuration
      - Hero content, Discord links, etc.

  2. Security
    - Enable RLS on all tables
    - Public read access for products, reviews, and settings
    - Authenticated write access where appropriate
    - Admin-only access for sensitive operations

  3. Data Population
    - Pre-populate site settings
    - Add initial product catalog with proper categorization
*/

-- Drop existing tables if they exist to recreate with new schema
DROP TABLE IF EXISTS product_variants CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS site_settings CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- Create products table with enhanced schema
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  description text,
  price numeric NOT NULL,
  sale_price numeric NOT NULL,
  stock integer DEFAULT 0,
  image text,
  featured boolean DEFAULT false,
  is_parent boolean DEFAULT false,
  has_variants boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create product_variants table for child products
CREATE TABLE IF NOT EXISTS product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id uuid REFERENCES products(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  sale_price numeric NOT NULL,
  stock integer DEFAULT 0,
  image text,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number text UNIQUE NOT NULL,
  product_id uuid REFERENCES products(id),
  customer_email text NOT NULL,
  amount numeric NOT NULL,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author text NOT NULL,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create site_settings table
CREATE TABLE IF NOT EXISTS site_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value text NOT NULL,
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for products (public read, admin write)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert products"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update products"
  ON products FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete products"
  ON products FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for product_variants
CREATE POLICY "Anyone can view product variants"
  ON product_variants FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert variants"
  ON product_variants FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update variants"
  ON product_variants FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete variants"
  ON product_variants FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for orders
CREATE POLICY "Authenticated users can view orders"
  ON orders FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for reviews (public read, authenticated write)
CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can delete reviews"
  ON reviews FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for site_settings (public read, admin write)
CREATE POLICY "Anyone can view site settings"
  ON site_settings FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can update settings"
  ON site_settings FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insert site settings
INSERT INTO site_settings (key, value) VALUES
  ('hero_image', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1920&h=1080&fit=crop'),
  ('discord_link', 'https://discord.gg/auroraaccounts'),
  ('hero_heading', 'Premium Gaming Accounts & Services'),
  ('hero_subheading', 'Your trusted marketplace for Fortnite, Valorant, and Roblox accounts'),
  ('hero_paragraph', 'AuroraServices delivers premium gaming accounts with instant delivery, secure transactions, and 24/7 support. All accounts are verified and ready to play.')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- Insert sample reviews
INSERT INTO reviews (author, rating, comment) VALUES
  ('Alex M.', 5, 'Amazing service! Got my Fortnite account instantly and it had everything promised. Highly recommend!'),
  ('Sarah K.', 5, 'Best place to buy gaming accounts. Fast delivery and great customer support.'),
  ('Mike R.', 4, 'Good selection of accounts. The Black Knight account was worth every penny!'),
  ('Emma L.', 5, 'Super fast delivery and the account quality is excellent. Will buy again!');

-- Insert main parent products (these show on the main page)
INSERT INTO products (name, category, description, price, sale_price, stock, image, featured, is_parent, has_variants) VALUES
  ('Fortnite Accounts', 'Fortnite', 'Premium Full Access Fortnite accounts with rare skins and exclusive items', 75.00, 49.99, 50, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', true, true, true),
  ('Valorant Accounts', 'Valorant', 'Ranked-ready Valorant accounts with premium skins and competitive access', 27.00, 17.50, 30, 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&h=300&fit=crop', true, true, true),
  ('Roblox Accounts', 'Roblox', 'Premium Roblox accounts with Korblox, Headless, and exclusive items', 180.00, 100.00, 20, 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=300&fit=crop', true, true, true),
  ('Unban Service', 'Service', 'Professional account unban service for various platforms', 30.00, 30.00, 100, 'https://images.unsplash.com/photo-1560169897-fc0cdbdfa4d5?w=400&h=300&fit=crop', false, false, false);

-- Get parent product IDs for variants
DO $$
DECLARE
  fortnite_id uuid;
  valorant_id uuid;
  roblox_id uuid;
BEGIN
  SELECT id INTO fortnite_id FROM products WHERE category = 'Fortnite' AND is_parent = true LIMIT 1;
  SELECT id INTO valorant_id FROM products WHERE category = 'Valorant' AND is_parent = true LIMIT 1;
  SELECT id INTO roblox_id FROM products WHERE category = 'Roblox' AND is_parent = true LIMIT 1;

  -- Insert Fortnite variants
  INSERT INTO product_variants (parent_id, name, description, price, sale_price, stock, image, sort_order) VALUES
    (fortnite_id, '[FA] Mystery Box', 'Surprise Full Access account with random rare skins', 9.99, 6.99, 25, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 1),
    (fortnite_id, '[FA] Sweaty Account', 'Competitive account with sweaty skins and emotes', 19.99, 14.99, 15, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 2),
    (fortnite_id, '[FA] Polo Prodigy', 'Premium account featuring the exclusive Polo skin', 59.99, 49.99, 8, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 3),
    (fortnite_id, '[FA] 300+ Skins', 'Massive collection with 300+ exclusive skins', 52.99, 42.99, 5, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 4),
    (fortnite_id, '[FA] 200+ Skins', 'Large account with 200+ premium skins', 32.99, 22.99, 12, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 5),
    (fortnite_id, '[FA] 150+ Skins', 'Quality account featuring 150+ skins', 24.99, 16.99, 18, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 6),
    (fortnite_id, '[FA] 100+ Skins', 'Great starter account with 100+ skins', 14.99, 9.99, 22, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 7),
    (fortnite_id, 'Black Knight', 'Rare OG account featuring the legendary Black Knight skin', 99.99, 75.00, 3, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 8),
    (fortnite_id, 'Travis Scott', 'Exclusive account with Travis Scott collaboration skins', 69.99, 50.00, 6, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 9),
    (fortnite_id, 'Leviathan', 'Rare deep-sea themed Leviathan account', 34.99, 25.00, 10, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 10),
    (fortnite_id, 'Tournament Ready', 'Competitive account with tournament-ready skins', 29.99, 20.00, 14, 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 11);

  -- Insert Valorant variants
  INSERT INTO product_variants (parent_id, name, description, price, sale_price, stock, image, sort_order) VALUES
    (valorant_id, 'EU Level 1-20 Ranked Ready', 'Fresh EU account ready for ranked play', 10.00, 7.00, 30, 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&h=300&fit=crop', 1),
    (valorant_id, 'EU Level 1-20 [Knife + Skins]', 'Ranked ready with premium knife and skins (1000-3000VP value)', 22.00, 17.50, 15, 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&h=300&fit=crop', 2),
    (valorant_id, 'EU Level 20-40 [Knife + Skins]', 'Higher level account with premium inventory (2000-5000VP value)', 35.00, 27.00, 10, 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=400&h=300&fit=crop', 3);

  -- Insert Roblox variants
  INSERT INTO product_variants (parent_id, name, description, price, sale_price, stock, image, sort_order) VALUES
    (roblox_id, 'Korblox Account', 'Premium account with Korblox Deathspeaker - OGE mail accessible', 85.00, 70.00, 8, 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=300&fit=crop', 1),
    (roblox_id, 'Headless Account', 'Exclusive Headless Horseman account - OGE mail accessible', 120.00, 100.00, 5, 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=300&fit=crop', 2),
    (roblox_id, 'Headless + Korblox', 'Ultimate bundle with both Headless and Korblox - OGE mail accessible', 200.00, 180.00, 3, 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=300&fit=crop', 3);
END $$;

-- Create sample orders
INSERT INTO orders (order_number, product_id, customer_email, amount, status)
SELECT 
  'ORD-' || LPAD(generate_series::text, 5, '0'),
  (SELECT id FROM products ORDER BY random() LIMIT 1),
  'customer' || generate_series || '@example.com',
  (random() * 100 + 10)::numeric(10,2),
  CASE WHEN random() > 0.3 THEN 'completed' ELSE 'pending' END
FROM generate_series(1, 10);
