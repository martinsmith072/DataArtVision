-- ============================================================
-- Track Contest — RESET
-- Wipes all entries, ballots and play counts. Settings and
-- database structure survive — you're back to an empty contest.
-- Run in Supabase → SQL Editor whenever needed.
--
-- Reminder: testers should also clear their browser's site data
-- (or use a private window) so the app forgets their
-- "already voted / already streamed" flags.
-- ============================================================

delete from ballots;
delete from submissions;

-- NOTE: Uploaded files can NO LONGER be cleared from SQL.
-- Supabase blocks direct deletes on storage.objects
-- (trigger storage.protect_delete → "Direct deletion from storage
-- tables is not allowed. Use the Storage API instead.").
--
-- To empty the uploaded MP3s / cover art, do it in the dashboard:
--   Storage → tracks bucket → select all → Delete
-- (or call the Storage API with the service_role key).
