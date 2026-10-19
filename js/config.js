// Instellingen van de clubapp.

// De WordPress-site waar nieuws, verslagen, en foto's vandaan komen.
export const SITE = 'https://wijnandkoetsier.nl';

// Programma, uitslagen, standen, teams, agenda en sponsors. Zolang dit endpoint nog niet
// bestaat (zie wordpress/vve-app-api.php), gebruikt de app de momentopname in data/snapshot.json.
export const APP_ENDPOINT = `${SITE}/wp-json/vve/v1/app`;

// Categorie-slugs in WordPress.
export const CAT_VERSLAGEN = 'wedstrijdverslagen';

export const INSTAGRAM = 'vvelspeet';

// Supabase (zelfde project als Elspeet Fluit) voor de spelerscijfers en Speler van het jaar.
// De anon key mag openbaar zijn; de beveiliging zit in supabase/speler-van-het-jaar.sql.
export const SUPABASE_URL = 'https://ggeznlthmfngumelpjss.supabase.co';
export const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnZXpubHRobWZuZ3VtZWxwanNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIxMzgzNzQsImV4cCI6MjEwNzcxNDM3NH0.V-VG0ZDwa7NJPCqTDnhoTUj1daaVRjWMb14QSyL5ro8';

// Het team waarvan de spelers cijfers krijgen.
export const RATING_TEAM = 'Elspeet 1';
