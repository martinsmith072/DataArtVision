-- ============================================================
-- Track Contest — RESET
-- Wipes all entries, ballots, play counts and uploaded files.
-- Settings and database structure survive — you're back to an
-- empty contest. Run in Supabase → SQL Editor whenever needed.
--
-- Reminder: testers should also clear their browser's site data
-- (or use a private window) so the app forgets their
-- "already voted / already streamed" flags.
-- ============================================================

delete from ballots;
delete from submissions;
delete from storage.objects where bucket_id = 'tracks';
