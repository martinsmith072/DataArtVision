# Track Contest — README & Setup

A team music contest: upload AI-generated tracks under anonymous band names, vote Eurovision-style, watch the chart. The app is a single `index.html` hosted free on Netlify; Supabase (free tier) stores the MP3s, cover art, votes and play counts.

**How it works:** anyone with the link can listen, no sign-in. To vote or submit a track, people just type their name — it's stored privately (to block duplicate ballots and give you a review trail) but never displayed. Zero admin beyond flipping the contest phases.

**Files in this repo:**

| File | What it is |
|---|---|
| `index.html` | The entire app |
| `setup.sql` | Database setup — run once in Supabase's SQL Editor |
| `reset.sql` | Wipes test data — run whenever you want a clean slate |
| `README.md` | This guide |

## The update workflow (GitHub + Claude Code + Netlify)

One-time: connect Netlify to this GitHub repo (**Add new site → Import an existing project → GitHub** → pick the repo). After that:

1. Open Claude Code in this folder and describe the change in plain English.
2. Say "commit and push".
3. Netlify auto-deploys the push — live in about a minute.

If an update breaks something, the Netlify dashboard lists every previous deploy — one click restores the last working version.

**SQL is the exception:** database changes never deploy through GitHub. They're run by hand in Supabase → SQL Editor. The `.sql` files here are the record of what's been run, so keep them updated if Claude Code changes the schema.

---

## 1. Create the Supabase project

1. Go to https://supabase.com → sign up (free, no card) → **New project**.
2. Name it anything (e.g. `track-contest`), pick the London region, set a database password (you won't need it again).
3. Wait ~1 minute for it to provision.

## 2. Create the storage bucket

1. Left menu → **Storage** → **New bucket**.
2. Name it exactly: `tracks`
3. Toggle **Public bucket** ON → Save.

## 3. Run the database setup

Left menu → **SQL Editor** → **New query**. Open **`setup.sql`** from this repo, copy the whole thing, paste, click **Run**. Nothing to edit — it creates the tables, the stream counter, and the access rules in one go.

## 4. Wire up the app

1. In Supabase: **Project Settings → API**. Copy the **Project URL** and the **anon public** key.
2. Open `index.html` in a text editor. Near the top of the script:

```js
const SUPABASE_URL = "PASTE_YOUR_PROJECT_URL_HERE";
const SUPABASE_ANON_KEY = "PASTE_YOUR_ANON_KEY_HERE";
```

3. Paste your two values in and save.

## 5. Host it on Netlify (free)

**Recommended:** Netlify → **Add new site → Import an existing project → GitHub** → pick this repo. Every future push then deploys automatically.

(Quick alternative for a one-off test: drag the project folder onto https://app.netlify.com/drop.)

Share the URL — and rename the site to something friendlier in Site settings.

---

## Running the contest

Control the phases from Supabase → **Table Editor** → `settings` (edit the single row):

| Phase | submissions_open | voting_open |
|---|---|---|
| Collecting tracks | `true` | `false` |
| Voting week | `false` | `true` |
| Closed / final reveal | `false` | `false` |

- **The app has two views**: the home page ("The Chart") shows every track with play buttons and stream counts, and — once unlocked — the points leaderboard on the same page. "Enter a track" is the upload form. During voting, ranking happens inline on the home page: tap Rank on each track and the ballot builds at the top.
- **Anyone with the link** can listen and see stream counts — no name needed.
- **To vote or enter**, people type their name once; the browser remembers it.
- **Points are hidden** on the home page until a person has voted (or voting closes), so nobody's ballot is influenced by the running order. The moment their ballot is cast, the same page re-sorts into the live chart.
- **Band names**: the app only ever shows band names. Real names live in the `submissions` table for your eyes only — the unmasking is yours to stage-manage.
- **Scoring** is Eurovision: 1st = 12, 2nd = 10, 3rd = 8, then 7 down to 1. Under 11 entries, everyone ranks every track (so every song scores); with 11+ entries, voters rank their top 10. A voter's own track is hidden from their ballot (matched by the name they typed).
- **Chart** unlocks per person once their ballot is in; when you set `voting_open` to `false` it becomes the public reveal.
- **Streams** count once per track per browser — indicative fun, not audited numbers.

## Keeping it honest (your 2-minute review)

Open **Table Editor → ballots**. You'll see `voter_name`, `rankings` and a timestamp. Things to look for if results smell off:

- Names you don't recognise, or near-duplicates ("Dave", "Dave S", "DaveSmith") cast close together in time.
- Delete a suspicious row and that ballot's points vanish from the chart instantly.
- If it turns into a stuffing contest, set `voting_open` to `false` and you've frozen everything while you tidy up.

To fix genuine mistakes (wrong upload, re-vote request), delete that person's row in `submissions` or `ballots` the same way.

## Clearing test data

After your dry run (or any time you want a clean slate), run **`reset.sql`** from this repo in the **SQL Editor**. It wipes all entries, ballots, play counts and uploaded files; settings and structure survive, so you're back to an empty contest.

Testers should also clear the site data in their browser (or use a private window) so the app forgets their "already voted / already streamed" flags — otherwise your test browser will think you've voted when the real contest starts.

## Honest small print

- Anonymity is at the app level. Real names are in the database (that's how duplicates are blocked and how you review) and the app never displays them — but someone determined and technical could inspect the API with the anon key. Fine for a fun contest; not cryptographic secrecy.
- Voting is honour-system by design: nothing stops "Dave 2" from voting twice under two names. Your review trail is the deterrent, and you can close voting at any moment.
- Free tier storage is 1GB — comfortably 100+ tracks with artwork. The app caps uploads at 20MB per MP3 and 5MB per image.
