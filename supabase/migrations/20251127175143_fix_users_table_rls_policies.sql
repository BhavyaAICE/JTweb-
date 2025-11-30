/*
  # Fix Users Table RLS Policies
  
  The users table had RLS enabled but no policies, preventing new users from being created
  during authentication. This migration adds the necessary policies:
  
  1. Users can insert their own record when they sign up
  2. Users can read their own profile
  3. Admins can read all users
  
  This allows the authentication flow to work properly while maintaining security.
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Admins can read all users" ON users;

-- Allow authenticated users to insert their own record
CREATE POLICY "Users can insert own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Allow authenticated users to read their own profile
CREATE POLICY "Users can read own profile"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Allow admins to read all users
CREATE POLICY "Admins can read all users"
  ON users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
      AND u.role = 'admin'
    )
  );
