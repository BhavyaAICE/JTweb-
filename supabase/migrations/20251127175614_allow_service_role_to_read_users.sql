/*
  # Allow Service Role Access to Users Table
  
  The service role key needs to be able to read users to determine admin status.
  This migration adds a policy that allows the service role to bypass RLS
  by using the appropriate privilege level.
*/

-- Add public access for role checks (needed for queries on role field)
-- This allows the admin check to work without recursion
CREATE POLICY "Public can read user roles"
  ON users
  FOR SELECT
  TO anon, authenticated
  USING (true);
