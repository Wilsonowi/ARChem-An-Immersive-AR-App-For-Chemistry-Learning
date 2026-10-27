-- ARChem RAG knowledge base
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).

create extension if not exists vector;

create table if not exists chemistry_knowledge (
  id bigint generated always as identity primary key,
  source_id text not null,
  chapter_number int not null,
  chapter_title text not null,
  topic_number text not null,
  topic_title text not null,
  section text not null,
  content text not null,
  embedding vector(768) not null,
  created_at timestamptz not null default now()
);

-- RLS is enabled with no policies: the table cannot be read or written directly
-- by anon/authenticated clients. The seed script writes via the service_role key
-- (which bypasses RLS), and the app only reads through the SECURITY DEFINER
-- function below.
alter table chemistry_knowledge enable row level security;

create or replace function match_chemistry_knowledge(
  query_embedding vector(768),
  match_count int default 5
)
returns table (
  id bigint,
  chapter_number int,
  chapter_title text,
  topic_number text,
  topic_title text,
  section text,
  content text,
  similarity float
)
language sql
stable
security definer
set search_path = public
as $$
  select id, chapter_number, chapter_title, topic_number, topic_title, section, content,
         1 - (embedding <=> query_embedding) as similarity
  from chemistry_knowledge
  order by embedding <=> query_embedding
  limit match_count;
$$;

grant execute on function match_chemistry_knowledge(vector, int) to authenticated;
