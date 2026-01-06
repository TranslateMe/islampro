const crypto = require('crypto')

// Netlify Function: RevenueCat webhook receiver
// - Verifies X-RevenueCat-Signature using HMAC-SHA1 (webhook secret)
// - Inserts a normalized row into the `subscription_events` table via Supabase REST (service role key)

// Required environment variables (set in Netlify site settings):
// REVENUECAT_WEBHOOK_SECRET - RevenueCat webhook secret (starts with sk_...)
// SUPABASE_URL - e.g. https://<project>.supabase.co
// SUPABASE_SERVICE_ROLE_KEY - Supabase service_role key (secret)

const SUPABASE_TABLE = 'subscription_events'

function safeEqual(a, b) {
  if (!a || !b) return false
  const bufA = Buffer.from(a)
  const bufB = Buffer.from(b)
  if (bufA.length !== bufB.length) return false
  return crypto.timingSafeEqual(bufA, bufB)
}

exports.handler = async function (event, context) {
  try {
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET
    if (!secret) {
      console.error('Missing REVENUECAT_WEBHOOK_SECRET env var')
      return { statusCode: 500, body: 'Server misconfigured' }
    }

    const signatureHeader = event.headers['x-revenuecat-signature'] || event.headers['X-RevenueCat-Signature'] || event.headers['x-revenuecat-signature'.toLowerCase()]
    if (!signatureHeader) {
      console.warn('Missing signature header')
      return { statusCode: 400, body: 'Missing signature' }
    }

    // RevenueCat signs the raw request body. Compute HMAC-SHA1.
    const hmac = crypto.createHmac('sha1', secret)
    hmac.update(event.body || '')
    const expected = hmac.digest('hex')

    // signatureHeader may be like "sha1=..." or just the hex
    const sig = signatureHeader.includes('=') ? signatureHeader.split('=')[1] : signatureHeader
    if (!safeEqual(expected, sig)) {
      console.warn('Invalid signature')
      return { statusCode: 401, body: 'Invalid signature' }
    }

    const payload = JSON.parse(event.body)

    // Attempt to normalize common RevenueCat webhook shapes
    // RevenueCat payloads vary; extract best-effort fields
    const eventType = payload?.type || payload?.event || payload?.webhook_type || payload?.data?.type || payload?.event?.type || null
    const appUserId = payload?.app_user_id || payload?.original_app_user_id || payload?.data?.app_user_id || payload?.event?.app_user_id || payload?.event?.original_app_user_id || null
    const productId = payload?.product_id || payload?.data?.product_id || payload?.event?.product_id || payload?.event?.subscription?.product_id || null
    const purchaseDate = payload?.purchase_date || payload?.data?.purchase_date || payload?.event?.purchase_date || null
    const expirationDate = payload?.ms_since_renewal ? null : (payload?.expiration_date || payload?.data?.expiration_date || payload?.event?.expiration_date || null)
    const transactionId = payload?.transaction_id || payload?.data?.transaction_id || payload?.event?.transaction_id || null
    const originalTransactionId = payload?.original_transaction_id || payload?.data?.original_transaction_id || payload?.event?.original_transaction_id || null
    const environment = payload?.environment || payload?.data?.environment || payload?.event?.environment || 'PRODUCTION'

    // Build row - only set fields if present. Supabase will default created_at.
    const row = {
      revenuecat_app_user_id: appUserId,
      event_type: eventType,
      product_id: productId,
      transaction_id: transactionId,
      original_transaction_id: originalTransactionId,
      purchase_date: purchaseDate,
      expiration_date: expirationDate,
      environment: environment,
      raw_payload: payload
    }

    // Remove undefined keys
    Object.keys(row).forEach(k => row[k] === undefined && delete row[k])

    // Insert into Supabase via REST (use service role key)
    const supabaseUrl = process.env.SUPABASE_URL
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    if (!supabaseUrl || !supabaseKey) {
      console.error('Missing Supabase env vars')
      return { statusCode: 500, body: 'Supabase not configured' }
    }

    const insertUrl = `${supabaseUrl.replace(/\/$/, '')}/rest/v1/${SUPABASE_TABLE}`
  const res = await fetch(insertUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify([row])
    })

    if (!res.ok) {
      const text = await res.text()
      console.error('Supabase insert failed', res.status, text)
      return { statusCode: 502, body: 'Failed to write to DB' }
    }

    const inserted = await res.json()
    console.log('Inserted subscription event', inserted)

    return { statusCode: 200, body: JSON.stringify({ status: 'ok' }) }
  } catch (err) {
    console.error('Webhook handler error', err)
    return { statusCode: 500, body: 'internal error' }
  }
}
