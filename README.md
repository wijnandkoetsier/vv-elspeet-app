# VV Elspeet

De clubapp van V.V. Elspeet: programma en uitslagen, nieuws, wedstrijdverslagen, media, teams, Elspeet 1, over de club, sponsoren, agenda en contact. Werkt in de browser en is te installeren op de telefoon (PWA), zonder App Store.

Losse app, naast de scheidsrechtersapp Elspeet Fluit. Alle content komt van de clubwebsite (WordPress).

Zie [VOORSTEL.md](VOORSTEL.md) voor het plan, de onderdelen, de databronnen en de fasering.

## Lokaal bekijken

```bash
npx http-server -c-1 .
# open http://localhost:8080/
```

## Online zetten

GitHub → **Settings → Pages → Source: GitHub Actions**. Bij elke merge naar `main` publiceert `.github/workflows/pages.yml` de app.

Geen build-stap: gewone HTML/CSS/JavaScript.

## Spelerscijfers en Speler van het jaar (eenmalig instellen)

Bij elke gespeelde wedstrijd van Elspeet 1 (of een wedstrijd van vandaag) kan iedereen in de app de spelers een cijfer geven: 1 t/m 10 per halve punt, of een streepje voor niet gespeeld. Onder **Meer → Speler van het jaar** staat de stand: het gemiddelde cijfer per speler over het seizoen.

De cijfers staan in hetzelfde Supabase-project als Elspeet Fluit. Eenmalig:

1. Open Supabase → **SQL Editor**.
2. Plak de inhoud van [`supabase/speler-van-het-jaar.sql`](supabase/speler-van-het-jaar.sql) en klik **Run**.

Spelers toevoegen of op non-actief zetten kan daarna in Supabase → **Table Editor → rating_players**.
