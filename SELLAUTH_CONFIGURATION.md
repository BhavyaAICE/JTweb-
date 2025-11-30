# SellAuth Configuration Guide

## What Changed

Your checkout integration has been updated to use SellAuth's official embed SDK instead of direct URL navigation. This fixes the blank page issue when clicking "Buy Now".

## How SellAuth Checkout Works Now

1. **Embed SDK Loaded**: The SellAuth embed script is now loaded in `index.html`
2. **Modal Checkout**: When users click "Buy Now", a checkout modal appears instead of redirecting
3. **Proper Integration**: Uses SellAuth's recommended `window.sellAuthEmbed.checkout()` method

## Required Configuration

### 1. Get Your SellAuth Product IDs

In your SellAuth Dashboard at https://dash.sellauth.com:

1. Go to **Products**
2. Click on a product
3. Note the **numeric Product ID** (e.g., `12345`, not a long string)
4. If the product has variants, also note the **Variant ID** for each variant

### 2. Configure Products in Your Admin Panel

#### For Regular Products (No Variants):

1. Log into your admin panel
2. Go to **Products Management**
3. Edit a product
4. Enter the numeric **SellAuth Product ID** (e.g., `12345`)
5. Save

#### For Products with Variants:

1. Log into your admin panel
2. Go to **Variants Management**
3. Select the parent product
4. Edit each variant
5. Enter:
   - **SellAuth Product ID**: The main product ID from SellAuth
   - **SellAuth Variant ID**: The specific variant ID (if applicable)
6. Save

### 3. Verify Your Shop ID

Your `.env` file should have:

```env
VITE_SELLAUTH_SHOP_ID=195561
```

This is already configured.

## Testing the Checkout

1. **Click "Buy Now"** on any product
2. A **checkout modal should appear** (not a blank page)
3. If it says "Checkout is loading, please try again", wait a moment for the SDK to load
4. Complete a test purchase using SellAuth's test mode

## Common Issues

### "This product does not have a SellAuth product ID configured"
- Make sure you entered a numeric Product ID in the admin panel
- Check that it's not empty or "0"

### "Checkout is loading, please try again"
- The SellAuth embed script is still loading
- Wait 1-2 seconds and try again
- Check browser console for script loading errors

### Checkout modal doesn't appear
- Open browser console (F12) and check for JavaScript errors
- Verify the SellAuth embed script loaded: check Network tab for `embed-2.js`
- Ensure Shop ID is configured correctly in `.env`

## Technical Details

### Files Changed:
1. `index.html` - Added SellAuth embed script
2. `src/lib/sellauth.js` - Created helper for checkout integration
3. `src/components/ProductCard.jsx` - Updated to use embed SDK
4. `src/components/ProductVariantsModal.jsx` - Updated to use embed SDK
5. `src/pages/CartPage.jsx` - Updated to use embed SDK
6. `src/pages/AdminDashboard.jsx` - Added variant ID fields
7. Database - Added `sellauth_variant_id` column to product_variants table

### How It Works:
```javascript
window.sellAuthEmbed.checkout({
  shopId: 195561,  // Your shop ID
  cart: [
    {
      productId: 12345,     // Numeric product ID
      variantId: 67890,     // Optional variant ID
      quantity: 1
    }
  ],
  modal: true  // Opens in modal instead of new tab
});
```

## Next Steps

1. Get your SellAuth product IDs
2. Enter them in the admin panel
3. Test the checkout flow
4. Deploy to production
