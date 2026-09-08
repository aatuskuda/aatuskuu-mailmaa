# Aatusku Maailma — toimiva Supabase + PayPal -versio

Tämä versio käyttää Supabase Authia ja Postgresia selaimen `localStorage`-demon sijaan.
Tuotteiden omistajuus suojataan Supabase RLS -politiikoilla. PayPal order/capture tehdään
Cloudflare Pages Functions -palvelimella.

## 1. Supabase

1. Luo Supabase-projekti.
2. Avaa SQL Editor.
3. Aja `supabase.sql` kokonaan.
4. Ota Email/Password Auth käyttöön.
5. Avaa Settings → API Keys ja kopioi projektin URL sekä Publishable key.
6. Täytä ne `config.js`:ään.

Älä laita secret/service_role-avainta `config.js`:ään.

## 2. PayPal sandbox

Cloudflare Pages → Settings → Variables and Secrets:

- `PAYPAL_CLIENT_ID`
- `PAYPAL_CLIENT_SECRET`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

PayPal secret kuuluu vain Cloudflare Functions -ympäristöön.

## 3. Cloudflare Pages

Projektin juuressa on `index.html` ja `functions/`-hakemisto.
Yhdistä GitHub-repository Cloudflare Pagesiin. Staattiselle projektivaiheelle build command
voi olla `exit 0`.

## 4. Tärkeä marketplace-rajoitus

Tämä versio tekee oikean PayPal Checkout -tilauksen palvelimen kautta, mutta PayPal Checkout
veloittaa maksun sovelluksen/merchant-tilin konfiguraation mukaisesti. Se ei vielä toteuta
monimyyjä-marketplacea, jossa jokainen myyjä onboardataan ja saa rahansa suoraan omalle
PayPal-tililleen. Se vaatii erillisen PayPal marketplace/multiparty-ratkaisun.

## 5. Tuotantoon ennen julkaisua

- vaihda PayPal sandbox live-endpointteihin ja tuotannon tunnuksiin
- määritä oikeat return/cancel-osoitteet omalle domainille
- lisää maksun webhook/idempotenssi ja tilauksen lopullinen server-side validointi
- harkitse tuotteiden varaamista ennen capturea, jotta samaa tuotetta ei voi ostaa kahdesti
- tarkista Supabase Security Advisor ja RLS-testit

