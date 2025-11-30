# SellAuth - Quick Start (10 Minutes)

## What You Need to Do RIGHT NOW

### Step 1: Create Products in SellAuth (2 min)

1. Go to https://dash.sellauth.com/
2. Navigate to **Products**
3. Click **Create Product**
4. Fill in:
   - Name: "Product Name"
   - Price: "9.99"
   - Description: "What they get"
   - Any other details
5. **Save and copy the Product ID** (you'll see it listed)
6. **Repeat for each product you want to sell**

### Step 2: Add SellAuth IDs to Your Website (3 min)

1. Open your website
2. **Log into Admin Panel** (admin account)
3. Go to **Products Management**
4. Click **Edit** on first product
5. Paste **SellAuth Product ID** in the field
6. Click **Save Product**
7. **Repeat for all products**

### Step 3: Test a Purchase (2 min)

1. Click **"Buy Now"** on any product
2. Should redirect to SellAuth checkout
3. Use test card: **4242 4242 4242 4242**
4. Expiry: Any future date
5. CVC: Any 3 digits
6. Complete purchase

### Step 4: Verify It Worked (3 min)

1. Check **Admin Panel → Orders**
   - Should see your test order
2. Check **Products**
   - Stock should have decreased by 1
3. Go to https://dash.sellauth.com/
   - Check **Webhooks → Logs**
   - Should show successful event

---

## That's It! You're Ready to Sell

Your website is now:
- ✅ Accepting payments via SellAuth
- ✅ Tracking orders automatically
- ✅ Updating product stock
- ✅ Recording sales in admin panel

---

## Next: Deploy to Live Domain

### Quick Deploy (Choose One)

**Option A: Vercel (Easiest)**
```bash
npm install -g vercel
vercel login
vercel --prod
```
Then add env variables in Vercel dashboard.

**Option B: Netlify**
- Go to https://netlify.com
- Connect your Git repo
- Auto-deploys on every push

**See DEPLOYMENT_SELLAUTH.md for detailed instructions**

---

## Credentials (Already Set Up)

```
Shop ID: 195561 (Aurora Services)
Webhook: Connected to your Supabase
```

---

## Webhook Endpoint

```
https://kmafvuiinuqibxjzlqmz.supabase.co/functions/v1/sellauth-webhook
```

Already configured! Handles all payments automatically.

---

## Important Environment Variables

These are in your `.env` file:

```env
VITE_SELLAUTH_SHOP_ID=195561
VITE_SUPABASE_URL=https://kmafvuiinuqibxjzlqmz.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
```

For production, set these same variables in your hosting dashboard.

---

## What Each Component Does

**ProductCard Component** (`src/components/ProductCard.jsx`)
- Reads SellAuth Product ID
- Redirects to SellAuth checkout on "Buy Now"

**Admin Dashboard** (`src/pages/AdminDashboard.jsx`)
- Let's you add/edit SellAuth Product IDs
- Shows all orders received
- Tracks product stock

**Webhook Edge Function** (`supabase/functions/sellauth-webhook/index.ts`)
- Receives payment events from SellAuth
- Creates order records
- Decreases product stock

**Database Tables**
- `products` - Has `sellauth_product_id` column (replaced `sellix_product_id`)
- `orders` - Stores `sellauth_order_id` when customer buys

---

## Troubleshooting

### Product doesn't open SellAuth
- Make sure you added SellAuth Product ID in admin panel
- Restart dev server if you just added env variables

### No orders showing up
- Check SellAuth Dashboard → Webhooks → Logs
- Verify webhook delivered successfully
- Check that you actually completed payment (not just filled form)

### "SellAuth is not configured"
- Verify `VITE_SELLAUTH_SHOP_ID=195561` in .env
- Restart dev server
- For production, check hosting env variables

---

## What Happens When Customer Buys

1. **Customer clicks** "Buy Now"
2. **Redirected to** SellAuth checkout at dash.sellauth.com
3. **Customer pays** (test or real payment)
4. **SellAuth processes** payment securely
5. **Your server gets** webhook notification
6. **Order record created** (appears in admin)
7. **Stock automatically** decreased by 1
8. **Customer gets** access to product

All automatic - you don't have to do anything!

---

## Adding More Products Later

1. Create product in SellAuth Dashboard
2. Copy SellAuth Product ID
3. Add product to your website via admin panel
4. Paste SellAuth ID
5. Save
6. Done! Ready to sell immediately

---

## Files That Changed

| File | Changes |
|------|---------|
| `.env` | Added SellAuth credentials |
| `src/components/ProductCard.jsx` | Uses SellAuth instead of Sellix |
| `src/pages/AdminDashboard.jsx` | Uses `sellauth_product_id` field |
| `supabase/functions/sellauth-webhook/` | New webhook handler for SellAuth |
| Database | Added `sellauth_product_id` column to products |

---

## SellAuth Dashboard Links

- **Main Dashboard:** https://dash.sellauth.com/
- **Products:** https://dash.sellauth.com/products
- **Webhooks:** https://dash.sellauth.com/settings/webhooks
- **Orders:** https://dash.sellauth.com/orders
- **Support:** https://dash.sellauth.com/support

---

## Next Steps

1. ✅ Create products in SellAuth
2. ✅ Add SellAuth IDs to website
3. ✅ Test purchase
4. ✅ Deploy to production
5. ✅ Go live and start selling!

---

**Need more help?** See:
- `SELLAUTH_SETUP.md` - Detailed setup guide
- `DEPLOYMENT_SELLAUTH.md` - Deployment instructions
- https://dash.sellauth.com/support - SellAuth support
