-- Fix: Quiz History screen cannot retrieve past MCQ attempts.
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).
--
-- `quiz_history` predates this project's supabase/migrations/ convention -
-- it was created directly in the dashboard back when the only code that
-- touched it was SupabaseService.saveQuizQuestion(s) (INSERT only, from the
-- MCQ quiz and diagnostic test). QuizHistoryService.fetchMcqAttempts()
-- (added this session) is the first and only code path that ever SELECTs
-- from this table - if the table was created with row level security
-- enabled but only an insert policy (a common oversight for a table nobody
-- needed to read back from at the time), every read returns zero rows
-- (or is rejected outright), which is exactly the "cannot retrieve quiz
-- history" symptom this fixes.

alter table quiz_history enable row level security;

drop policy if exists "Users can read their own quiz history" on quiz_history;

create policy "Users can read their own quiz history"
  on quiz_history for select
  using (auth.uid() = user_id);

-- Re-affirm the insert policy too, in case it was never actually created
-- and the table has instead been relying on RLS being off entirely.
drop policy if exists "Users can insert their own quiz history" on quiz_history;

create policy "Users can insert their own quiz history"
  on quiz_history for insert
  with check (auth.uid() = user_id);
