-- ARChem AI answer-marking history
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).
-- Stores the OCR'd text + marking result for each photographed handwritten
-- answer a student submits to "Mark My Answer". The photo itself is never
-- uploaded/stored - only the extracted text and the AI's structured result.

create table if not exists answer_submissions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  chapter text not null,
  chapter_number int not null,
  question_text text not null,
  ocr_text text not null,
  ocr_confidence float,
  score numeric not null,
  max_score numeric not null,
  breakdown jsonb not null default '[]',
  explanation text,
  matched_reference_ids text[] not null default '{}',
  created_at timestamptz not null default now()
);

-- Unlike chemistry_knowledge (read only via a SECURITY DEFINER RPC), this
-- table is read/written directly by the client, so it needs real RLS
-- policies scoped to the owning user.
alter table answer_submissions enable row level security;

create policy "Users can insert their own submissions"
  on answer_submissions for insert
  with check (auth.uid() = user_id);

create policy "Users can read their own submissions"
  on answer_submissions for select
  using (auth.uid() = user_id);
