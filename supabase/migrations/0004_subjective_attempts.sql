-- ARChem subjective quiz attempt history
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).
-- Stores the final marked result of a subjective quiz attempt: the 3
-- generated questions, the student's typed answers, and Gemini's marking.
-- Generated questions/mark schemes and in-progress answers live only in
-- Riverpod state during the attempt - only the finished, marked result is
-- persisted here.

create table if not exists subjective_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  chapter text not null,
  chapter_number int not null,
  questions jsonb not null default '[]',
  total_awarded int not null,
  total_possible int not null,
  created_at timestamptz not null default now()
);

-- Same as answer_submissions: read/written directly by the client, so it
-- needs real RLS policies rather than a SECURITY DEFINER RPC.
alter table subjective_attempts enable row level security;

create policy "Users can insert their own subjective attempts"
  on subjective_attempts for insert
  with check (auth.uid() = user_id);

create policy "Users can read their own subjective attempts"
  on subjective_attempts for select
  using (auth.uid() = user_id);
