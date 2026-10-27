-- ARChem weekly, AI-adjustable study plan.
-- Run this once in the Supabase SQL editor (Project -> SQL Editor -> New query -> Run).
--
-- Parallel, independent system from the legacy stage-based `study_plans`
-- table (lib/study_plan/) - intentionally does not touch that table, its
-- policies, or any code that reads/writes it.
--
-- One row per user per ISO week (Monday-Sunday), holding the whole week's
-- scheduled study blocks as JSON.
--
-- INTENTIONAL SIMPLIFICATION (flagged for revisit): chapters/subtopics not
-- studied by the end of a week are dropped when the next week's plan is
-- generated - there is no carry-over into the following week. See
-- WeeklyPlanService.generatePlan() in lib/weekly_plan/services/weekly_plan_service.dart.
--
-- Unlike the other tables in this project (insert-only history logs), this
-- one is adjusted in place after creation (via the AI adjustment dialog),
-- so it needs an UPDATE policy too.

create table if not exists weekly_study_plans (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  week_start_date date not null, -- the Monday that starts this week
  plan jsonb not null default '{}', -- { "days": { "monday": [StudyBlock, ...], ... } }
  generated_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, week_start_date)
);

alter table weekly_study_plans enable row level security;

create policy "Users can insert their own weekly study plans"
  on weekly_study_plans for insert
  with check (auth.uid() = user_id);

create policy "Users can read their own weekly study plans"
  on weekly_study_plans for select
  using (auth.uid() = user_id);

create policy "Users can update their own weekly study plans"
  on weekly_study_plans for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
