# QiblaFinder Privacy Policy - Deployment Instructions for islampro.life

## File to Deploy

**File**: `qiblafinder-privacy-policy.html`
**Location**: `/Users/nikitaguzenko/Desktop/QIbla-app/privacy-policy-web/qiblafinder-privacy-policy.html`

---

## Recommended URLs for islampro.life

Choose one of these URL structures:

### Option 1: Dedicated Path (Recommended)
```
https://islampro.life/privacy
```
**File placement**: Upload to `/qiblafinder/privacy/index.html` OR `/qiblafinder/privacy.html`

### Option 2: Direct File
```
https://islampro.life/privacy
```
**File placement**: Upload to root as `/qiblafinder-privacy.html`

### Option 3: Apps Subdirectory
```
https://islampro.life/privacy
```
**File placement**: Upload to `/apps/qiblafinder/privacy/index.html`

---

## Instructions for Claude Code (Other Terminal)

Tell Claude Code in your other terminal:

### **Simple Instruction**:
```
Please upload the file located at:
/Users/nikitaguzenko/Desktop/QIbla-app/privacy-policy-web/qiblafinder-privacy-policy.html

To my islampro.life website at the URL:
https://islampro.life/privacy

Make sure the file is accessible and test the URL works.
```

### **Detailed Instruction** (if needed):
```
I need to deploy a privacy policy HTML file to my islampro.life website.

File location: /Users/nikitaguzenko/Desktop/QIbla-app/privacy-policy-web/qiblafinder-privacy-policy.html

Desired URL: https://islampro.life/privacy

Please:
1. Connect to my islampro.life hosting
2. Create the /qiblafinder/privacy/ directory if needed
3. Upload the HTML file as index.html
4. Set proper permissions (644 for file, 755 for directory)
5. Test the URL is accessible
6. Confirm the final URL

The file is a complete, self-contained HTML page (includes all CSS, no external dependencies).
```

---

## What Claude Code Will Need

Depending on your hosting setup, Claude Code might ask for:

- **FTP/SFTP credentials** (host, username, password, port)
- **SSH access** (if using SSH/SCP)
- **cPanel/control panel** access
- **Git repository** (if site is deployed via Git)
- **Hosting provider** (e.g., Vercel, Netlify, AWS, shared hosting)

---

## File Details

### Self-Contained
- ✅ Complete HTML with embedded CSS
- ✅ No external dependencies (no images, no external CSS/JS files)
- ✅ Mobile-responsive design
- ✅ Works immediately after upload
- ✅ File size: ~15 KB (very small)

### Contact Email
   - Email: `support@islampro.life` (already configured in the HTML)

### Styling
- Apple-style clean design
- Green checkmarks (✓) for "yes" items
- Red X marks (✗) for "no" items
- Blue highlight boxes for important info
- Fully responsive (mobile-friendly)

---

## After Deployment

Once deployed by Claude Code, you'll get a URL like:
```
https://islampro.life/privacy
```

### What to Do Next:

1. **Test the URL**:
   - Open in browser
   - Verify it displays correctly
   - Test on mobile device

2. **Use in App Store Connect**:
   - Navigate to App Information
   - Find "Privacy Policy URL" field
   - Paste: `https://islampro.life/privacy`
   - Save

3. **Save the URL**:
   - Keep it for future reference
   - Add to your documentation
   - Share with team if applicable

---

## Verification Checklist

After Claude Code deploys, verify:

- [ ] URL is accessible (no 404 error)
- [ ] Page displays correctly (formatted, styled)
 - [ ] Email shows: privacy@islampro.life
- [ ] Mobile responsive (test on phone)
- [ ] HTTPS is enabled (secure connection)
- [ ] No broken links or images
- [ ] Fast loading time

---

## Alternative: Quick Deploy Commands

If you have direct SSH/SCP access, these commands work:

### Via SCP (if you have SSH access):
```bash
scp /Users/nikitaguzenko/Desktop/QIbla-app/privacy-policy-web/qiblafinder-privacy-policy.html \
   user@islampro.life:/path/to/webroot/qiblafinder/privacy/index.html
```

### Via FTP (using lftp):
```bash
lftp -u username,password ftp.islampro.life <<EOF
cd public_html/qiblafinder/privacy
put /Users/nikitaguzenko/Desktop/QIbla-app/privacy-policy-web/qiblafinder-privacy-policy.html -o index.html
bye
EOF
```

---

## Troubleshooting

### "404 Not Found" after upload
- Check file is named correctly (`index.html` in directory OR `.html` file)
- Verify permissions: file should be 644
- Clear browser cache
- Check if directory exists

### Page shows as plain text (no styling)
- Ensure file uploaded as `.html` (not `.txt`)
- Check MIME type is `text/html`
- Verify HTML isn't being escaped/encoded

### HTTPS not working
- Ask hosting provider to enable SSL for subdirectory
- May need to add SSL certificate for subdomain
- Use Cloudflare or Let's Encrypt for free SSL

---

## Final URL for App Store Connect

Once deployed and tested, your Privacy Policy URL will be:

```
https://islampro.life/privacy
```

**Save this URL** - you'll enter it in App Store Connect under:
- App Information → Privacy Policy URL

---

## Server-side: RevenueCat webhook (optional but recommended)

I added a Netlify Function to receive RevenueCat webhooks and write subscription events into the Supabase `subscription_events` table. This is more reliable than relying on client-side sync alone.

Files added (in repo):
- `netlify-site/functions/revenuecat-webhook.js` — validates RevenueCat signature and inserts into Supabase via REST.

Required environment variables (Netlify site settings → Build & deploy → Environment):
- `REVENUECAT_WEBHOOK_SECRET` = your RevenueCat webhook secret (starts with `sk_...`)  
- `SUPABASE_URL` = your Supabase project URL (e.g. `https://<project>.supabase.co`)  
- `SUPABASE_SERVICE_ROLE_KEY` = Supabase service_role key (secret)

Deploy steps:
1. Push the repository changes (the function file is already added locally in the repo). Netlify will auto-deploy on push if the site is connected to GitHub.
2. In Netlify, add the three environment variables above.
3. Find the function URL after deploy: `https://<your-site-alias>/.netlify/functions/revenuecat-webhook` and paste it into RevenueCat Dashboard → Webhooks → Add Webhook URL.
4. Use RevenueCat Dashboard to send a test webhook — the function will verify the `X-RevenueCat-Signature` and insert a row into `subscription_events`.

Testing locally:
- You can use `netlify dev` to run functions locally and test with a sample payload. Ensure `REVENUECAT_WEBHOOK_SECRET` is set in your local environment when testing.

Security note:
- Do NOT commit service role keys or secrets into the repo. Use Netlify environment variables (or other secret stores).
- After testing, rotate any keys that were exposed in chat or logs.


---

## Notes

- File is production-ready (no changes needed)
- All contact info is already correct (sales@731labs.net)
- Policy is GDPR & CCPA compliant
- Apple will verify this URL is accessible during review
- Policy can be updated anytime (no app resubmission needed)

---

**Status**: ✅ File ready for deployment
**Next Action**: Give instructions to Claude Code in other terminal
**Expected Time**: 5-10 minutes for deployment and verification
