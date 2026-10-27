-- ARChem AI tutor chat history
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).
-- Stores each question/answer turn from the AI Tutor chat. The app only
-- ever reads back the most recent 10 turns (ORDER BY created_at DESC LIMIT
-- 10) - older rows are kept (not deleted) for potential future history
-- features, matching how quiz_history/answer_submissions/
-- subjective_attempts never prune either.

create table if not exists chat_history (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  question text not null,
  answer text not null,
  created_at timestamptz not null default now()
);

alter table chat_history enable row level security;

create policy "Users can insert their own chat turns"
  on chat_history for insert
  with check (auth.uid() = user_id);

create policy "Users can read their own chat turns"
  on chat_history for select
  using (auth.uid() = user_id);
