-- Adds columns for the upgraded OCR extraction, which now reads the
-- question text and its allocated marks directly off the photo (instead of
-- the student typing the question and marking always being out of a fixed
-- 10) and reports confidence per-field instead of one overall score.
-- Run this once in the Supabase SQL editor, after 0002_answer_submissions.sql.

alter table answer_submissions
  add column if not exists marks_allocated int,
  add column if not exists question_confidence text,
  add column if not exists marks_confidence text,
  add column if not exists answer_confidence text;
