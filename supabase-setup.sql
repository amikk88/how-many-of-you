-- How Many of You? — database setup
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run.
-- Safe to run more than once.

create table if not exists public.games (
  id          text primary key check (id ~ '^g[a-z0-9]{8}$'),
  name        text not null check (char_length(name) between 1 and 40),
  us          bigint not null check (us > 0),
  world       bigint not null check (world > 0),
  us_place    jsonb not null,
  world_place jsonb not null,
  created_at  timestamptz not null default now()
);

create table if not exists public.plays (
  game_id    text not null references public.games(id) on delete cascade,
  player_id  text not null check (char_length(player_id) between 4 and 64),
  player     text not null check (char_length(player) between 1 and 24),
  us         text not null check (us in ('name', 'place')),
  world      text not null check (world in ('name', 'place')),
  us_ok      boolean,
  world_ok   boolean,
  score      int,
  created_at timestamptz not null default now(),
  primary key (game_id, player_id)   -- one entry per player per game
);

-- Added later: which spellings a game counts (e.g. ["Sarah","Sara"]). Empty means exact spelling only.
alter table public.games add column if not exists spellings jsonb
  check (spellings is null or jsonb_typeof(spellings) = 'array');

-- Scores are worked out by the database, so nobody can post a fake score.
create or replace function public.score_play() returns trigger
language plpgsql security definer set search_path = public as $$
declare g public.games;
begin
  select * into g from public.games where id = new.game_id;
  if not found then raise exception 'game not found'; end if;
  new.us_ok    := new.us    = case when g.us    > (g.us_place->>'p')::bigint    then 'name' else 'place' end;
  new.world_ok := new.world = case when g.world > (g.world_place->>'p')::bigint then 'name' else 'place' end;
  new.score    := new.us_ok::int + new.world_ok::int;
  new.created_at := now();
  return new;
end $$;

drop trigger if exists score_play on public.plays;
create trigger score_play before insert on public.plays
  for each row execute function public.score_play();

-- Anyone may read games and scores and add new ones. Nobody can edit or delete through the website.
alter table public.games enable row level security;
alter table public.plays enable row level security;

drop policy if exists "Anyone can read games" on public.games;
drop policy if exists "Anyone can create games" on public.games;
drop policy if exists "Anyone can read plays" on public.plays;
drop policy if exists "Anyone can add a play" on public.plays;

create policy "Anyone can read games"   on public.games for select to anon, authenticated using (true);
create policy "Anyone can create games" on public.games for insert to anon, authenticated with check (true);
create policy "Anyone can read plays"   on public.plays for select to anon, authenticated using (true);
create policy "Anyone can add a play"   on public.plays for insert to anon, authenticated with check (true);

grant select, insert on public.games, public.plays to anon, authenticated;
