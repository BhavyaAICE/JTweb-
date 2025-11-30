# SellAuth Deployment & Hosting Guide

## Quick Start: Deploy in 5 Minutes

### Prerequisites
- Node.js 18+ installed
- Git repository set up
- SellAuth account at https://dash.sellauth.com/

---

## Option 1: Deploy to Vercel (Easiest)

Vercel is perfect for React apps and offers free hosting with automatic deployments.

### Step 1: Create Vercel Account
1. Go to https://vercel.com/
2. Sign up with GitHub, GitLab, or email
3. Connect your Git repository

### Step 2: Deploy Your App

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel
```

Follow the prompts:
- Confirm project name
- Keep default settings
- Wait for deployment to complete

You'll get a URL like: `https://auroraservices.vercel.app`

### Step 3: Add Environment Variables

1. **Go to:** https://vercel.com/dashboard
2. **Click your project**
3. **Go to:** Settings → Environment Variables
4. **Add these variables:**

| Name | Value |
|------|-------|
| `VITE_SUPABASE_URL` | `https://kmafvuiinuqibxjzlqmz.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | [From your .env] |
| `VITE_SELLAUTH_SHOP_ID` | `195561` |

5. **Redeploy:**
```bash
vercel --prod
```

### Step 4: Update SellAuth Webhook (Optional)

If you want webhook events to go to your Vercel URL instead of Supabase:

1. Go to SellAuth Dashboard → Webhooks
2. Update webhook URL to:
   ```
   https://yourapp.vercel.app/.well-known/sellauth-webhook
   ```
3. Save

---

## Option 2: Deploy to Netlify

Netlify is great for static sites with easy CI/CD from Git.

### Step 1: Connect Git Repository

1. Go to https://netlify.com/
2. Sign up with GitHub
3. Click "New site from Git"
4. Select your repository
5. Click "Deploy site"

Netlify automatically builds and deploys on every git push!

### Step 2: Add Environment Variables

1. **Go to:** Site Settings → Environment Variables
2. **Add:**
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `VITE_SELLAUTH_SHOP_ID`

3. **Trigger redeploy** or push to git

### Step 3: Configure Build Settings

Netlify should auto-detect your build settings, but verify:

**Build command:** `npm run build`
**Publish directory:** `dist`

---

## Option 3: Deploy to Traditional Hosting

### Using Your Own Server or Hosting Provider

#### Step 1: Build Your App

```bash
npm run build
```

This creates a `dist/` folder with all your static files.

#### Step 2: Upload Files

Upload the `dist/` folder to your hosting provider:
- cPanel/Shared Hosting: Use FTP or File Manager
- VPS/Dedicated: Use `scp` or `rsync`
- AWS S3: Upload to S3 bucket
- Google Cloud Storage: Upload to bucket

#### Step 3: Set Environment Variables

For production builds, environment variables must be set during build time.

Create a production `.env` file with:
```env
VITE_SUPABASE_URL=https://kmafvuiinuqibxjzlqmz.supabase.co
VITE_SUPABASE_ANON_KEY=your_key_here
VITE_SELLAUTH_SHOP_ID=195561
```

Then rebuild:
```bash
npm run build
```

#### Step 4: Configure Web Server

**For Apache (.htaccess):**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**For Nginx:**
```nginx
server {
    listen 80;
    server_name yoursite.com;

    root /var/www/yoursite/dist;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
```

---

## Option 4: Deploy to Heroku

Heroku is great for apps with backend services.

### Step 1: Create Heroku App

```bash
# Install Heroku CLI
npm install -g heroku

# Login
heroku login

# Create app
heroku create your-app-name

# Add buildpack for Node.js
heroku buildpacks:add heroku/nodejs
```

### Step 2: Set Environment Variables

```bash
heroku config:set VITE_SUPABASE_URL=https://kmafvuiinuqibxjzlqmz.supabase.co
heroku config:set VITE_SUPABASE_ANON_KEY=your_key
heroku config:set VITE_SELLAUTH_SHOP_ID=195561
```

### Step 3: Deploy

```bash
git push heroku main
```

Your app will be live at: `https://your-app-name.herokuapp.com`

---

## Using Custom Domain

### For Any Hosting Provider

1. **Purchase a domain:**
   - Namecheap, GoDaddy, Google Domains, Route53, etc.
   - Cost: ~$10-15/year

2. **Point domain to hosting:**
   - Go to registrar's DNS settings
   - Update nameservers or A record to point to hosting provider
   - Wait 24 hours for DNS to propagate

3. **Enable HTTPS:**
   - Vercel/Netlify: Automatic free SSL
   - Traditional hosting: Use Let's Encrypt (free)
   - Heroku: Already included

4. **Update SellAuth Webhook URL:**
   - Go to SellAuth Dashboard → Webhooks
   - Update to: `https://yourdomain.com/functions/sellauth-webhook`

---

## SSL/HTTPS Certificate (Free)

### For Self-Hosted Servers: Let's Encrypt

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --nginx -d yourdomain.com

# Auto-renew
sudo certbot renew --dry-run
```

### For cPanel Hosting
- Go to AutoSSL
- Click "Issue" or "Reissue"
- Automatic renewal every 90 days

---

## Environment Variables Reference

These must be available in production:

```env
# Supabase (from your .env)
VITE_SUPABASE_URL=https://kmafvuiinuqibxjzlqmz.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# SellAuth
VITE_SELLAUTH_SHOP_ID=195561
```

**Note:** Variables starting with `VITE_` are exposed to the browser (public). Never put secret API keys with `VITE_` prefix. Private variables don't need `VITE_` prefix.

---

## Testing After Deployment

### 1. Check Website Loads
- Open https://yourdomain.com
- Verify homepage displays correctly
- Check all pages load

### 2. Test Admin Login
- Go to admin panel
- Log in with your credentials
- Verify you can see dashboards

### 3. Test Product Purchase
- Click "Buy Now" on a product
- Should redirect to SellAuth checkout
- Use test card: `4242 4242 4242 4242`
- Verify order appears in admin

### 4. Check Webhook
- Make test purchase
- Go to SellAuth Dashboard → Webhooks → Logs
- Verify webhook delivered successfully
- Check admin panel for order

---

## Monitoring & Logs

### Vercel
- Go to https://vercel.com/dashboard
- Click project
- Go to "Deployments" or "Functions"
- View logs and errors

### Netlify
- Go to https://app.netlify.com/
- Click site
- Go to "Deploys" or "Functions"
- View build logs

### Heroku
```bash
# View logs
heroku logs --tail

# View specific errors
heroku logs --tail | grep ERROR
```

### Traditional Hosting
- Check web server logs (usually in `logs/` folder)
- Check PHP error logs if applicable

---

## Performance Tips

### 1. Enable Caching
```bash
# In Nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 2. Enable Compression
```bash
# In Nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 3. Use CDN
- Vercel: Automatic edge network
- Netlify: Automatic CDN
- Traditional: Use Cloudflare (free)

---

## Troubleshooting

### Site Shows Blank Page
- Check browser console for errors (F12)
- Verify environment variables are set
- Check hosting provider's error logs
- Ensure `dist/` folder has `index.html`

### Products Don't Load
- Verify `VITE_SUPABASE_URL` is correct
- Check Supabase is online
- Verify RLS policies allow public read

### Checkout Redirects to Wrong URL
- Check `VITE_SELLAUTH_SHOP_ID` is set
- Verify admin panel has SellAuth Product IDs
- Check browser console for errors

### Webhook Not Working
- Verify webhook URL in SellAuth matches deployment URL
- Check SellAuth webhook logs for errors
- Verify webhook secret environment variable is set
- Check Supabase Edge Function logs

### CORS Errors
- This is normal for the webhook
- CORS headers are already configured
- If persistent, verify webhook URL is correct

---

## Cost Breakdown

| Platform | Cost | Notes |
|----------|------|-------|
| **Vercel** | Free-$20/mo | Free tier perfect for startups |
| **Netlify** | Free-$19/mo | Free tier includes decent limits |
| **Heroku** | Free-$50/mo | Paid plans required now |
| **Self-hosted** | $5-50/mo | Depending on provider |
| **Domain** | $12/year | Varies by registrar |
| **Supabase DB** | Free-$25/mo | Free tier has 500MB storage |

**Total minimum cost:** $12/year (domain only) on free tier platforms

---

## Next Steps

1. **Choose your hosting platform** (Vercel recommended)
2. **Deploy your app**
3. **Set environment variables**
4. **Configure custom domain** (optional)
5. **Test purchase flow**
6. **Update SellAuth webhooks**
7. **Monitor your site**

---

## Support Resources

- **Vercel Docs:** https://vercel.com/docs
- **Netlify Docs:** https://docs.netlify.com
- **Heroku Docs:** https://devcenter.heroku.com
- **SellAuth Support:** https://dash.sellauth.com/support
- **Supabase Docs:** https://supabase.com/docs

---

## Deployment Checklist

- [ ] Pushed code to git repository
- [ ] Created hosting account (Vercel/Netlify/etc)
- [ ] Deployed app
- [ ] Set environment variables
- [ ] Tested website loads
- [ ] Tested admin login
- [ ] Tested product checkout
- [ ] Tested webhook
- [ ] Updated SellAuth webhook URL
- [ ] Configured custom domain (optional)
- [ ] Enabled HTTPS/SSL
- [ ] Monitored first real sale

---

Your site is ready to go live! 🚀
