/*
  # Create users table

  1. New Tables
    - `users` - Stores user profile data
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `role` (text) - 'customer' or 'admin'
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on users table
*/

CREATE TABLE users (
  id uuid PRIMARY KEY,
  email text UNIQUE NOT NULL,
  role text DEFAULT 'customer',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
