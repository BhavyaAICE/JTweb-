# AuroraServices - Deployment & Sellix Integration Guide

## Table of Contents
1. [Sellix Setup](#sellix-setup)
2. [Environment Configuration](#environment-configuration)
3. [Testing Sellix Integration](#testing-sellix-integration)
4. [Deploying to Production](#deploying-to-production)
5. [Post-Deployment Checklist](#post-deployment-checklist)

---

## Sellix Setup

### Step 1: Create Sellix Account

1. Go to [Sellix.io](https://sellix.io) and create an account
2. Complete your shop setup and verification
3. Note your shop name (e.g., `yourshop` from `yourshop.mysellix.io`)

### Step 2: Get API Credentials

1. Log into [Sellix Dashboard](https://dashboard.sellix.io)
2. Navigate to **Developer** > **API Keys**
3. Click **Create API Key**
4. Copy the generated API key and save it securely
5. Navigate to **Settings** > **Webhooks**
6. Generate or copy your webhook secret

### Step 3: Create Products in Sellix

1. Go to **Products** in Sellix Dashboard
2. Click **Create Product**
3. Fill in product details (name, price, description, stock)
4. Set delivery type (usually "Serials" or "File")
5. Click **Create Product**
6. Copy the **Product ID** (you'll need this for each product)

### Step 4: Configure Webhook in Sellix

1. Navigate to **Settings** > **Webhooks**
2. Click **Add Webhook**
3. Enter your webhook URL:
   ```
   https://kmafvuiinuqibxjzlqmz.supabase.co/functions/v1/sellix-webhook
   ```
4. Select these events:
   - `order:paid`
   - `order:completed`
5. Save the webhook

---

## Environment Configuration

### Local Development (.env file)

Update your `.env` file with Sellix credentials:

```env
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttYWZ2dWlpbnVxaWJ4anpscW16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNjk5MzAsImV4cCI6MjA3OTc0NTkzMH0.H_KTCdd2GyBZLwnEdqCW-J8xTEo9Gz7T5iNbRq89FRs
VITE_SUPABASE_URL=https://kmafvuiinuqibxjzlqmz.supabase.co

# Sellix Configuration
VITE_SELLIX_SHOP_NAME=yourshop
SELLIX_API_KEY=your-sellix-api-key-here
SELLIX_WEBHOOK_SECRET=your-webhook-secret-here
```

### Supabase Edge Function Secrets

Set secrets for the webhook function:

```bash
# Using Supabase Dashboard:
# 1. Go to https://supabase.com/dashboard/project/kmafvuiinuqibxjzlqmz/settings/functions
# 2. Add these secrets:
#    - SELLIX_WEBHOOK_SECRET: your-webhook-secret
#    - SELLIX_API_KEY: your-api-key (if needed for API calls)
```

---

## Testing Sellix Integration

### Step 1: Link Products

1. Log into your admin panel at your deployed site
2. Go to **Products Management**
3. Edit each product
4. Add the **Sellix Product ID** from your Sellix Dashboard
5. Save the product

### Step 2: Test Purchase Flow

1. Open your website as a customer
2. Click "Buy Now" on a product with Sellix ID configured
3. You should be redirected to Sellix checkout page
4. Complete a test purchase using Sellix test mode:
   - Use test card: `4242 4242 4242 4242`
   - Any future expiry date
   - Any 3-digit CVC
5. After payment, webhook should trigger and create order in your database

### Step 3: Verify Webhook

1. Check Sellix Dashboard > **Webhooks** > **Logs**
2. Verify webhook was sent successfully
3. Check your admin panel > **Orders** to see the new order
4. Verify product stock was reduced

---

## Deploying to Production

### Option 1: Deploy to Vercel (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Deploy:**
   ```bash
   vercel
   ```

4. **Set Environment Variables in Vercel:**
   ```bash
   vercel env add VITE_SUPABASE_URL
   vercel env add VITE_SUPABASE_ANON_KEY
   vercel env add VITE_SELLIX_SHOP_NAME
   ```

5. **Deploy to Production:**
   ```bash
   vercel --prod
   ```

### Option 2: Deploy to Netlify

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify:**
   ```bash
   netlify login
   ```

3. **Initialize:**
   ```bash
   netlify init
   ```

4. **Build the project:**
   ```bash
   npm run build
   ```

5. **Deploy:**
   ```bash
   netlify deploy --prod --dir=dist
   ```

6. **Set Environment Variables:**
   - Go to Netlify Dashboard > Site Settings > Environment Variables
   - Add:
     - `VITE_SUPABASE_URL`
     - `VITE_SUPABASE_ANON_KEY`
     - `VITE_SELLIX_SHOP_NAME`

### Option 3: Deploy to GitHub Pages

1. **Install gh-pages:**
   ```bash
   npm install --save-dev gh-pages
   ```

2. **Add to package.json:**
   ```json
   {
     "scripts": {
       "predeploy": "npm run build",
       "deploy": "gh-pages -d dist"
     },
     "homepage": "https://yourusername.github.io/yourrepo"
   }
   ```

3. **Deploy:**
   ```bash
   npm run deploy
   ```

4. **Important:** GitHub Pages doesn't support environment variables at build time
   - You'll need to hardcode values or use a different hosting solution

---

## Post-Deployment Checklist

### 1. Verify Website Functionality

- [ ] Website loads correctly
- [ ] All images display properly
- [ ] Navigation works
- [ ] Product pages load
- [ ] Admin panel accessible

### 2. Test Sellix Integration

- [ ] "Buy Now" buttons redirect to Sellix
- [ ] Sellix checkout page loads
- [ ] Test purchase completes successfully
- [ ] Webhook processes order
- [ ] Order appears in admin panel
- [ ] Stock updates correctly
- [ ] Customer receives product delivery from Sellix

### 3. Configure DNS (Optional)

If using custom domain:

1. Add custom domain in your hosting provider
2. Configure DNS records:
   ```
   Type: CNAME
   Name: www
   Value: your-deployment-url
   ```
3. Update Sellix webhook URL to use custom domain

### 4. Enable Sellix Live Mode

1. In Sellix Dashboard, disable test mode
2. Configure real payment gateways
3. Test with small real purchase

### 5. Security Checklist

- [ ] All API keys stored securely
- [ ] Webhook signature validation enabled
- [ ] RLS policies active on database
- [ ] Admin accounts secured with strong emails
- [ ] Regular backups configured

---

## Troubleshooting

### Products Don't Link to Sellix

**Problem:** Clicking "Buy Now" shows alert instead of opening Sellix

**Solution:**
1. Verify `VITE_SELLIX_SHOP_NAME` is set correctly in .env
2. Ensure product has `sellix_product_id` set in admin panel
3. Check browser console for errors
4. Verify Sellix shop URL is accessible

### Webhook Not Working

**Problem:** Orders not appearing in admin panel after purchase

**Solution:**
1. Check Sellix Dashboard > Webhooks > Logs for errors
2. Verify webhook URL is correct
3. Ensure `SELLIX_WEBHOOK_SECRET` matches in both Sellix and Supabase
4. Check Supabase Edge Function logs
5. Verify database RLS policies allow service role to insert orders

### Stock Not Updating

**Problem:** Product stock doesn't decrease after purchase

**Solution:**
1. Verify webhook is processing correctly
2. Check that product IDs match between Sellix and your database
3. Ensure database has `sellix_order_id` column
4. Check admin panel order logs

---

## Support Resources

- **Sellix Documentation:** https://developers.sellix.io
- **Supabase Documentation:** https://supabase.com/docs
- **Vercel Documentation:** https://vercel.com/docs
- **Netlify Documentation:** https://docs.netlify.com

---

## Quick Reference

### Important URLs

- **Supabase Dashboard:** https://supabase.com/dashboard/project/kmafvuiinuqibxjzlqmz
- **Sellix Dashboard:** https://dashboard.sellix.io
- **Webhook URL:** https://kmafvuiinuqibxjzlqmz.supabase.co/functions/v1/sellix-webhook

### Environment Variables

| Variable | Where to Get It | Where to Set It |
|----------|----------------|-----------------|
| VITE_SELLIX_SHOP_NAME | Your shop name from Sellix URL | .env file & hosting provider |
| SELLIX_API_KEY | Sellix Dashboard > Developer > API Keys | Supabase Edge Function secrets |
| SELLIX_WEBHOOK_SECRET | Sellix Dashboard > Settings > Webhooks | .env & Supabase secrets |

---

## Next Steps

1. Complete Sellix setup and get all credentials
2. Update environment variables
3. Link products to Sellix
4. Test purchases in test mode
5. Deploy to production hosting
6. Enable live mode in Sellix
7. Monitor orders and sales
