# AuroraServices Setup Guide

## Authentication System

The application uses **Magic Link Authentication** via Supabase for secure access.

### Sign In (Log In)

1. Click the "Login" button in the navigation bar (a modal will appear)
2. Enter your email address
3. Click "Continue"
4. Check your email for a 6-digit verification code
5. Enter the 6-digit code in the modal
6. Click "Log In"
7. You'll be redirected based on your role:
   - **Customers** → Stay on current page
   - **Admins** → Admin dashboard

### Sign Out

1. Click the "Sign Out" button in the navigation bar
2. You'll be logged out and redirected to the home page

## Admin Account Setup

### Creating Your First Admin Account

1. **Sign in as a regular customer first**
   - Click the "Login" button in the navigation bar
   - Enter your admin email (e.g., `admin@auroraservices.com`)
   - Click "Continue"
   - Check your email for the 6-digit verification code
   - Enter the code and click "Log In"
   - You're now logged in as a customer

2. **Grant admin privileges in Supabase**
   - Open your [Supabase Dashboard](https://app.supabase.com/)
   - Select your project "auroraservices"
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"
   - Copy and paste this query:
   ```sql
   UPDATE users
   SET role = 'admin'
   WHERE email = 'admin@auroraservices.com';
   ```
   - Click "Run" button
   - You should see "1 row updated"

3. **Log out and log back in**
   - Click "Sign Out" in the navigation bar
   - Click the "Login" button again
   - Sign in again with your admin email
   - You'll now have full access to the admin dashboard

## Admin Panel Features

Once logged in as admin, you have full control over your store:

### Dashboard
- View key metrics: Total products, orders, reviews, and pending orders
- Quick overview of your store performance

### Products Management
- **Add New Product**: Create products with name, category, description, prices, stock, image URL, featured status, and variants option
- **Search & Filter**: Search by product name or category, filter by stock status or featured products
- **Quick Actions**:
  - Toggle featured status with star button
  - Increase/decrease stock with +/- buttons
  - View real-time stock status (In Stock/Low Stock/Out of Stock)
- **Edit Products**: Modify all product details including images
- **Delete Products**: Remove products from catalog
- **Has Variants Checkbox**: Enable this to create products with multiple sub-products (like Roblox with different Robux amounts)

### Stock Management
- See stock levels at a glance with color-coded badges
- Quickly adjust inventory with +/- buttons
- Products show "Out of Stock" when inventory is 0
- Products show "Low Stock" when inventory is below 10

### Pricing Control
- Set original and sale prices for each product
- Display strikethrough original price on storefront
- Highlight current sale price

### Orders Management
- View all customer orders
- See order number, product, customer email, amount, and status
- Track completed and pending orders

### Reviews Management
- View all customer reviews with ratings
- Delete inappropriate or spam reviews

### Variants Management
- **Select Parent Product**: Choose any product that has variants enabled
- **Add Variants**: Create multiple sub-products for a parent product (e.g., "Roblox 1000 Robux", "Roblox 5000 Robux")
- **Edit Variants**: Modify variant details including:
  - Name and description
  - Original price and sale price
  - Stock quantity
  - Image URL (can be different from parent product)
  - Sort order (controls display order on frontend)
- **Delete Variants**: Remove specific variants
- Each variant has its own stock, pricing, and image

### Site Settings
- Update hero image URL
- Modify Discord server link
- Edit hero heading, subheading, and paragraph text

## Customizable Features

Through the admin panel, you can customize:

- **Hero Image**: Change the main banner image on the homepage
- **Discord Link**: Update the Discord server invitation link
- **Hero Content**: Modify the heading, subheading, and paragraph text
- **Products**: Add, edit, or delete products
- **Reviews**: Manage customer reviews
- **Orders**: View and manage customer orders

## Default Settings

The application comes pre-configured with:
- Hero image from Unsplash
- Discord link: https://discord.gg/auroraaccounts
- Sample products and reviews
- Magic link authentication via Supabase

## Authentication Features

- Secure magic link authentication via Supabase
- One-time password (OTP) verification via email
- Modal-based login (no page redirect)
- Automatic user creation with admin/customer roles
- Role-based access control (admin/customer)
- Persistent sessions (stay logged in across page refreshes)
- Easy logout functionality from navbar

## Site Stats

- **Products**: 5
- **Happy Customers**: 300+
- **Vouches**: 900
- **Average Rating**: 4.8/5 (mostly 4 and 5 stars)

## Tech Stack

- React (JSX)
- Supabase (Database)
- Vite (Build tool)
- Pure CSS (No Tailwind)
