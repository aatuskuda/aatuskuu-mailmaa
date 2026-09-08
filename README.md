# Aatusku Maailma — Cloudflare Worker

Cloudflare Workers + Static Assets -versio.

Rakenne:
- `public/index.html` = sivusto
- `public/config.js` = vain Supabasen julkiset frontend-arvot
- `src/index.js` = PayPal-palvelinreitit
- `wrangler.json` = Cloudflare-konfiguraatio
- `supabase.sql` = tietokanta + RLS

Cloudflareen tarvitaan:
- `PAYPAL_CLIENT_ID`
- `PAYPAL_CLIENT_SECRET`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

PayPal secretia ei saa laittaa GitHubiin.

PayPal käyttää tässä paketissa Sandboxia testausta varten.
