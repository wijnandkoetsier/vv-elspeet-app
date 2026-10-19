-- Speler van het jaar: cijfers voor de spelers van Elspeet 1.
-- Eenmalig uitvoeren in Supabase → SQL Editor (veilig om te herhalen).
--
-- Iedereen in de app mag per gespeelde wedstrijd cijfers geven (1 t/m 10, per halve punt).
-- Elke telefoon heeft een eigen, geheime stem-code; opnieuw opslaan vervangt de eerdere stem.
-- De tabellen zelf zijn niet direct leesbaar of schrijfbaar: alles gaat via de functies
-- hieronder, zodat niemand de stemcodes van anderen kan zien of hun stem kan aanpassen.

create table if not exists public.rating_players (
  name   text primary key,
  sort   int  not null default 0,
  active boolean not null default true
);

insert into public.rating_players (name, sort) values
  ('Nick Dijkgraaf', 1), ('Tom van de Kolk', 2), ('Jasper Post', 3), ('Michel van de Hoek', 4),
  ('Erwin van Leeuwen', 5), ('Joran van Drunen', 6), ('Leon Post', 7), ('Chiel Noorderink', 8),
  ('Niels van de Steeg', 9), ('Robin Post', 10), ('Thijs Hazeleger', 11), ('Robin Smink', 12),
  ('Chiel Dijkgraaf', 13), ('Steyn Boer', 14), ('Stijn van Asselt', 15), ('David Bleijenberg', 16),
  ('Jorni van Zeist', 21), ('Bart van den Hoorn', 22)
on conflict (name) do nothing;

-- Niet meer in de selectie (blijven bewaard voor eerdere cijfers, maar staan niet meer in de app).
update public.rating_players set active = false
where name in ('Wim Kroes', 'Jan de Vos', 'Sigi Carrera', 'Elisa Plender');

create table if not exists public.player_ratings (
  id         bigint generated always as identity primary key,
  match_key  text not null,
  match_date date not null,
  season     text not null,
  voter      uuid not null,
  player     text not null references public.rating_players (name) on update cascade,
  score      numeric(3,1) not null check (score between 1 and 10 and score * 2 = round(score * 2)),
  created_at timestamptz not null default now(),
  unique (match_key, voter, player)
);
create index if not exists player_ratings_season on public.player_ratings (season, player);
create index if not exists player_ratings_match on public.player_ratings (match_key);

alter table public.rating_players enable row level security;
alter table public.player_ratings enable row level security;
drop policy if exists "spelers lezen" on public.rating_players;
create policy "spelers lezen" on public.rating_players for select to anon, authenticated using (active);
-- Bewust geen policies op player_ratings: alleen de functies hieronder komen erbij.
revoke all on public.player_ratings from anon, authenticated;

-- Seizoen loopt van 1 juli t/m 30 juni: 2026-10-24 → '2026/2027'.
create or replace function public.season_of(d date) returns text
language sql immutable as $$
  select case when extract(month from d) >= 7
    then extract(year from d)::int || '/' || (extract(year from d)::int + 1)
    else (extract(year from d)::int - 1) || '/' || extract(year from d)::int end;
$$;

-- Cijfers opslaan voor één wedstrijd. p_ratings: {"Spelernaam": 7.5, ...}; een streepje
-- (niet gespeeld) stuur je niet mee. Vervangt de eerdere stem van deze telefoon.
create or replace function public.submit_ratings(p_match_key text, p_match_date date, p_voter uuid, p_ratings jsonb)
returns int
language plpgsql security definer set search_path = public as $$
declare
  today date := (now() at time zone 'Europe/Amsterdam')::date;
  n int;
begin
  if p_match_key is null or length(p_match_key) > 200 then raise exception 'Ongeldige wedstrijd'; end if;
  if p_match_date > today then raise exception 'Deze wedstrijd is nog niet gespeeld'; end if;
  if p_match_date < today - 400 then raise exception 'Deze wedstrijd is te lang geleden'; end if;
  if jsonb_typeof(p_ratings) <> 'object' then raise exception 'Ongeldige cijfers'; end if;

  delete from player_ratings where match_key = p_match_key and voter = p_voter;
  insert into player_ratings (match_key, match_date, season, voter, player, score)
  select p_match_key, p_match_date, season_of(p_match_date), p_voter, r.key, (r.value #>> '{}')::numeric
  from jsonb_each(p_ratings) r
  join rating_players rp on rp.name = r.key and rp.active
  where jsonb_typeof(r.value) = 'number';
  get diagnostics n = row_count;
  return n;
end;
$$;

-- Gemiddelde per speler voor één wedstrijd.
create or replace function public.match_ratings(p_match_key text)
returns table (player text, avg numeric, votes int)
language sql stable security definer set search_path = public as $$
  select player, round(avg(score), 1), count(*)::int
  from player_ratings where match_key = p_match_key
  group by player order by 2 desc, 1;
$$;

-- De eigen stem van deze telefoon, om het formulier mee te vullen.
create or replace function public.my_ratings(p_match_key text, p_voter uuid)
returns table (player text, score numeric)
language sql stable security definer set search_path = public as $$
  select player, score from player_ratings where match_key = p_match_key and voter = p_voter;
$$;

-- Speler van het jaar: per wedstrijd eerst het gemiddelde van alle stemmen, daarna het
-- gemiddelde over de wedstrijden. Zo telt een wedstrijd met veel stemmers niet zwaarder.
create or replace function public.player_of_year(p_season text)
returns table (player text, avg numeric, matches int, votes int)
language sql stable security definer set search_path = public as $$
  with per_match as (
    select player, match_key, avg(score) as a, count(*) as c
    from player_ratings where season = p_season group by player, match_key
  )
  select player, round(avg(a), 2), count(*)::int, sum(c)::int
  from per_match group by player order by 2 desc, 3 desc, 1;
$$;

revoke all on function public.submit_ratings(text, date, uuid, jsonb) from public;
grant execute on function public.submit_ratings(text, date, uuid, jsonb) to anon, authenticated;
grant execute on function public.match_ratings(text) to anon, authenticated;
grant execute on function public.my_ratings(text, uuid) to anon, authenticated;
grant execute on function public.player_of_year(text) to anon, authenticated;
