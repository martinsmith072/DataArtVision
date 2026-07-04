-- ============================================================
-- Track Contest — one-time database setup
-- Run this ONCE in Supabase → SQL Editor → New query
-- (Then create the public storage bucket named "tracks" —
--  see README step 3 — and run the storage policies at the bottom.)
-- ============================================================

-- People may enter MULTIPLE tracks, each under its own band_name.
-- real_name is PRIVATE (never shown in the app) — it groups a person's
-- entries and hides their own tracks from their ballot. Peek at this
-- table after voting closes to find out who's who.
create table submissions (
  id uuid primary key default gen_random_uuid(),
  real_name text not null,
  band_name text not null,
  title text not null,
  audio_path text not null,
  cover_path text,
  plays int not null default 0,
  created_at timestamptz default now()
);
-- (No unique index on real_name — multiple entries per person are allowed.)

-- One ballot per name (case-insensitive: "dave" can't also vote as "Dave").
-- voter_name is your private review trail — the app never displays it.
create table ballots (
  id uuid primary key default gen_random_uuid(),
  voter_name text not null,
  rankings jsonb not null,
  created_at timestamptz default now()
);
create unique index one_ballot_per_name on ballots (lower(voter_name));

-- App switches you control from the Supabase dashboard (Table Editor)
create table settings (
  id int primary key default 1,
  submissions_open boolean not null default true,
  voting_open boolean not null default false
);
insert into settings (id) values (1);

-- Stream counter (called by the app when a track starts playing)
create or replace function log_play(track uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update submissions set plays = plays + 1 where id = track;
$$;
grant execute on function log_play(uuid) to anon;

-- Access rules
alter table submissions enable row level security;
alter table ballots enable row level security;
alter table settings enable row level security;

create policy "read submissions"  on submissions  for select using (true);
create policy "add submission"    on submissions  for insert with check (true);
create policy "read ballots"      on ballots      for select using (true);
create policy "cast ballot"       on ballots      for insert with check (true);
create policy "read settings"     on settings     for select using (true);

-- ============================================================
-- Storage policies — run AFTER creating the public bucket "tracks"
-- (Storage → New bucket → name: tracks → Public bucket: ON)
-- ============================================================

create policy "public read tracks"
  on storage.objects for select
  using (bucket_id = 'tracks');

create policy "team upload tracks"
  on storage.objects for insert
  with check (bucket_id = 'tracks');
