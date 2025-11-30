# SellAuth Integration - Complete Setup Guide

## Overview

Your AuroraServices e-commerce website is now integrated with SellAuth payment processing. This guide will walk you through setup, testing, and deployment to go live.

---

## 1. Verify SellAuth Credentials (Done!)

Your SellAuth credentials are already configured in the `.env` file:

```env
VITE_SELLAUTH_SHOP_ID=195561                                           # Aurora Services Shop ID
SELLAUTH_API_KEY=5366311|r2sbxlT1KtooYHWqqTxFFnZRfKmg5mZ5ggiT2mc40086c2a1
SELLAUTH_WEBHOOK_SECRET=f19eae06d2d1dfeb3acbbdb1978372f9da0fb65438d9c4ea6eb1fadf0b129f7b
```

---

## 2. Configure Webhook in SellAuth Dashboard

Your webhook endpoint is ready and will process all payment events.

### Set Up Webhook URL

1. **Go to:** https://dash.sellauth.com/
2. **Navigate to:** Settings → Webhooks or Developer → Webhooks
3. **Click:** Add Webhook
4. **Webhook URL:**
   ```
   https://kmafvuiinuqibxjzlqmz.supabase.co/functions/v1/sellauth-webhook
   ```
5. **Events to Listen For:**
   - `order.completed`
   - `order.paid`
   - Any other order-related events you want to track
6. **Webhook Secret:** Already configured on your server
7. **Save**

---

## 3. Create Products in SellAuth

For each product you want to sell:

### Create a Product in SellAuth

1. **Go to:** https://dash.sellauth.com/
2. **Navigate to:** Products → Create Product
3. **Fill in:**
   - **Product Name** - Display name for your product
   - **Price** - USD amount (e.g., 9.99)
   - **Description** - What the customer gets
   - **Category** (Optional) - Organize your products
   - **Stock** - How many units available (optional)
   - **Delivery Method** - Digital/Physical/Service
   - **Add files/deliverables** if digital product

4. **Click:** Save/Create Product
5. **Copy the Product ID** (looks like: `prod_abc123def456`)

---

## 4. Link Products to Your Website

Once you have SellAuth product IDs, link them to your website:

### Update Products in Admin Panel

1. **Open your website** in browser
2. **Log in** to your admin panel (admin account)
3. **Go to:** Products Management
4. **For each product:**
   - Click **Edit** button
   - Find the field: **SellAuth Product ID**
   - Paste the product ID from SellAuth
   - Click **Save Product**

**Example SellAuth Product ID:** `prod_xyz789abc123`

---

## 5. Test the Integration

### Test Purchase Flow (Local Testing)

1. **Make sure your website is running** (dev server or local build)
2. **Click "Buy Now"** on any product that has a SellAuth Product ID configured
3. You should be redirected to SellAuth checkout
4. **Use SellAuth's test mode:**
   - Test Card: `4242 4242 4242 4242`
   - Expiry: Any future date (e.g., 12/25)
   - CVC: Any 3 digits (e.g., 123)
   - Email: Any email address

### Verify Webhook Works

After completing a test purchase:

1. **Check SellAuth Dashboard:**
   - Go to Settings → Webhooks → Event Logs
   - Look for your webhook events (should show successful delivery)

2. **Check Your Admin Panel:**
   - Go to Orders Management
   - You should see the new order from your test purchase
   - Verify customer email, amount, and order status

3. **Verify Stock Decreased:**
   - Go to Products Management
   - Check that the product stock decreased by 1

---

## 6. Deploy to Production

### Option A: Deploy to Vercel (Recommended - Easiest)

```bash
# Step 1: Install Vercel CLI
npm install -g vercel

# Step 2: Login to Vercel
vercel login

# Step 3: Deploy
vercel
```

**Set environment variables in Vercel:**

1. Open your Vercel project dashboard
2. Go to Settings → Environment Variables
3. Add these variables:
   - `VITE_SUPABASE_URL` = `https://kmafvuiinuqibxjzlqmz.supabase.co`
   - `VITE_SUPABASE_ANON_KEY` = your anon key from .env
   - `VITE_SELLAUTH_SHOP_ID` = `195561`

4. Deploy to production:
```bash
vercel --prod
```

### Option B: Deploy to Netlify

```bash
# Step 1: Install Netlify CLI
npm install -g netlify-cli

# Step 2: Login to Netlify
netlify login

# Step 3: Initialize
netlify init

# Step 4: Build and deploy
npm run build
netlify deploy --prod --dir=dist
```

**Set environment variables in Netlify:**

1. Go to Site Settings → Environment Variables
2. Add:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_SELLAUTH_SHOP_ID`

### Option C: Deploy to Any Hosting (Heroku, Railway, Render, etc.)

```bash
npm run build
```

Upload the `dist/` folder to your hosting provider and set the same environment variables.

---

## 7. Update Webhook URL for Production

Once deployed, update your webhook URL if needed:

1. **Get your production URL** (e.g., `https://yoursite.vercel.app`)
2. **Go to SellAuth Dashboard:**
   - Settings → Webhooks
   - Edit your webhook
   - Update the URL to:
     ```
     https://yoursite.vercel.app/.netlify/functions/sellauth-webhook
     ```
   - Or keep the Supabase webhook URL (recommended) - it works for all domains

---

## 8. Go Live Checklist

- [ ] SellAuth products created with all details
- [ ] Products linked in admin panel with SellAuth Product IDs
- [ ] Webhook tested with test payment
- [ ] Orders appear in admin panel
- [ ] Stock automatically decreases
- [ ] Website deployed to production
- [ ] Production URL set in SellAuth webhooks (if needed)
- [ ] Disabled SellAuth test mode (ready for real payments)
- [ ] Configured real payment processors in SellAuth

---

## Your Webhook Endpoint

```
https://kmafvuiinuqibxjzlqmz.supabase.co/functions/v1/sellauth-webhook
```

This endpoint handles all payment events from SellAuth and:
- Creates order records
- Decreases product stock
- Updates order status
- Tracks payment information

---

## What Happens When a Customer Buys?

1. **Customer clicks** "Buy Now" on your website
2. **Redirected to** SellAuth checkout
3. **Customer enters** payment details and completes purchase
4. **SellAuth processes** the payment securely
5. **Webhook fires** to your server with order details
6. **Your server:**
   - Creates an order record in the database
   - Decreases product stock by 1
   - Stores payment information
7. **Order appears** in your Admin Panel → Orders
8. **Customer notified** by SellAuth with delivery details

---

## How to Add More Products

Whenever you want to add a new product:

1. **Create in SellAuth:**
   - https://dash.sellauth.com/
   - Products → Create Product
   - Fill all details and save

2. **Add to Website:**
   - Admin Panel → Products Management
   - Click "Add New Product"
   - Fill in product details
   - Paste the SellAuth Product ID
   - Save

3. **Start Selling:**
   - Product immediately appears on your website
   - Customers can purchase right away

---

## Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `VITE_SELLAUTH_SHOP_ID` | Your SellAuth shop identifier | `195561` |
| `SELLAUTH_API_KEY` | For API requests to SellAuth | `5366311\|r2sbx...` |
| `SELLAUTH_WEBHOOK_SECRET` | Verifies webhook signatures | `f19eae0...` |
| `VITE_SUPABASE_URL` | Your database URL | `https://kmafvuii...` |
| `VITE_SUPABASE_ANON_KEY` | Public API key for frontend | `eyJhbGc...` |

---

## Troubleshooting

### "SellAuth is not configured" Error
- Verify `VITE_SELLAUTH_SHOP_ID` is set in .env
- Restart dev server after changing .env
- For production, ensure env vars are set in hosting provider dashboard

### Webhook Not Receiving Events
- Check SellAuth Dashboard → Webhooks → Event Logs
- Verify webhook URL is correct
- Ensure webhook secret matches (already configured)
- Check Supabase Edge Function logs

### Product Doesn't Open SellAuth
- Ensure product has `sellauth_product_id` set in admin panel
- Verify product exists in SellAuth Dashboard
- Check browser console for any JavaScript errors

### Orders Not Appearing in Admin
- Check webhook logs in SellAuth Dashboard
- Verify webhook was received and triggered
- Check Supabase database for order records
- Verify webhook signature validation passed

---

## Advanced: Connect Custom Domain

If you want to use your own domain (e.g., `auroraservices.com`):

1. Purchase domain from registrar (Namecheap, GoDaddy, etc.)
2. Configure DNS to point to your hosting provider
3. Add SSL certificate (free with most hosting)
4. Update webhook URL in SellAuth to use your custom domain
5. Test that everything still works

**For Vercel:** https://vercel.com/docs/concepts/projects/domains
**For Netlify:** https://docs.netlify.com/domains-https/custom-domains

---

## Get Help

**SellAuth Support:** https://dash.sellauth.com/support
**SellAuth Docs:** https://docs.sellauth.com
**Check the webhook logs:** https://dash.sellauth.com/webhooks

---

## Quick Command Reference

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Deploy to Vercel
vercel --prod

# Deploy to Netlify
netlify deploy --prod --dir=dist

# View logs locally
npm run build
```

---

Great! Your SellAuth integration is complete. You're now ready to start selling! 🚀
