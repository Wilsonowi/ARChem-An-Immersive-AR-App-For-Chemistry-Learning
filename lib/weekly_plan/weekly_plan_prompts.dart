import 'dart:convert';

import '../chapters/chapters_data.dart';
import '../models/question_model.dart';
import 'models/weekly_study_plan_model.dart';

/// All Gemini prompt strings for the weekly study plan feature, kept in one
/// place for easy tuning (same pattern as
/// lib/subjective_quiz/subjective_quiz_prompts.dart).
class WeeklyPlanPrompts {
  WeeklyPlanPrompts._();

  static const int maxBlocksWeekday = 2;
  static const int maxBlocksWeekend = 3;
  static const String weekdaySlots = '19:00-20:00, 20:15-21:15';
  static const String weekendSlots = '10:00-11:00, 11:15-12:15, 15:00-16:00';

  static String generationPrompt({
    required DateTime weekStartDate,
    required List<ChapterDiagnosticScore> scores,
  }) {
    final catalogue = kChapters
        .map(
          (c) =>
              'Chapter ${c.number} "${c.title}" - subtopics: '
              '${c.subtopics.map((s) => '"$s"').join(', ')}',
        )
        .join('\n');

    final scoresJson = jsonEncode(scores.map((s) => s.toJson()).toList());

    return 'You are building a one-week (Monday-Sunday) Chemistry study '
        'schedule for a Malaysian SPM Form 4 Chemistry student, starting '
        '${_isoDate(weekStartDate)} (Monday). This app teaches Chemistry '
        'ONLY - never schedule any other subject, and never invent a '
        'chapter or subtopic outside the exact catalogue below.\n\n'
        'Chapter catalogue (the only valid chapters/subtopics):\n'
        '$catalogue\n\n'
        'The student\'s current per-chapter quiz performance (score/'
        'max_score; a chapter absent from this list has not been attempted '
        'yet and should be treated as needing the most attention):\n'
        '$scoresJson\n\n'
        'Planning priority:\n'
        '- Sort chapters from weakest score percentage to strongest.\n'
        '- Put the weakest chapters earlier in the week.\n'
        '- Give weak chapters more blocks than strong chapters.\n'
        '- If a chapter has 0 score or has not been attempted, treat it as '
        'urgent.\n'
        '- Strong chapters can appear only as short review blocks after weak '
        'chapters have been scheduled.\n'
        '- Do not make a generic timetable; every block must be justified by '
        'the score data.\n\n'
        'Scheduling rules:\n'
        '- Monday to Friday: at most $maxBlocksWeekday study blocks per day, '
        'chosen only from these fixed time slots: $weekdaySlots.\n'
        '- Saturday and Sunday: at most $maxBlocksWeekend study blocks per '
        'day, chosen only from these fixed time slots: $weekendSlots.\n'
        '- A rest day (no blocks) for a given day is allowed and sometimes '
        'appropriate - do not force blocks onto every single day.\n'
        '- Each block covers exactly one chapter and one subtopic from that '
        'chapter\'s exact subtopic list above.\n\n'
        'Return only valid JSON, no markdown fences, no commentary, with '
        'exactly this schema: {"days":{"monday":[{"chapterNumber":0,'
        '"chapterTitle":"...","subtopic":"...","startTime":"19:00",'
        '"endTime":"20:00"}],"tuesday":[],"wednesday":[],"thursday":[],'
        '"friday":[],"saturday":[],"sunday":[]}}. All 7 lowercase day keys '
        'must always be present, each mapping to an array (possibly empty).';
  }

  static String adjustmentPrompt({
    required String userRequest,
    required String selectedDayKey,
    required DateTime selectedDayDate,
    required DateTime deviceNow,
    required List<StudyBlock> selectedDayBlocks,
    required Map<String, List<StudyBlock>> restOfWeekBlocks,
  }) {
    final catalogue = kChapters
        .map(
          (c) =>
              'Chapter ${c.number} "${c.title}" - subtopics: '
              '${c.subtopics.map((s) => '"$s"').join(', ')}',
        )
        .join('\n');

    final selectedBlocksJson = jsonEncode(
      selectedDayBlocks.map((b) => b.toJson()).toList(),
    );
    final restOfWeekJson = jsonEncode({
      for (final entry in restOfWeekBlocks.entries)
        if (entry.key != selectedDayKey)
          entry.key: entry.value.map((b) => b.toJson()).toList(),
    });
    final deviceDateTime =
        '${_isoDate(deviceNow)} ${deviceNow.hour.toString().padLeft(2, '0')}:'
        '${deviceNow.minute.toString().padLeft(2, '0')}';

    return 'You are adjusting one Malaysian SPM Form 4 Chemistry student\'s '
        'weekly study schedule based on a short free-text request. The '
        'student is currently viewing $selectedDayKey '
        '(${_isoDate(selectedDayDate)}). The device current date/time is '
        '$deviceDateTime in the student\'s local timezone. Use this current '
        'time to interpret phrases like "today", "tonight", "later", '
        '"after this", and "tomorrow".\n\n'
        'That day\'s current blocks:\n$selectedBlocksJson\n\n'
        'The rest of the week\'s blocks, given only as read-only context '
        '(e.g. to avoid double-booking the same chapter on the same day '
        'elsewhere) - do not modify or return any of these unless the '
        'request clearly and specifically names a different day:\n'
        '$restOfWeekJson\n\n'
        'Chapter catalogue (the only valid chapters/subtopics):\n'
        '$catalogue\n\n'
        'Student\'s request: "$userRequest"\n\n'
        'First, silently identify the student\'s intent before editing:\n'
        '- ADD: phrases like "study again", "add one more", "later", '
        '"extra practice", or "I want to study tonight" mean add a block if '
        'a valid empty slot exists.\n'
        '- DELETE: phrases like "busy", "no time", "skip", "remove", '
        '"cancel", or "cannot study today" mean remove the affected block(s) '
        'for that day.\n'
        '- CHANGE SLOT: phrases like "not morning", "at night", "later", '
        '"move", "reschedule", or "change time" mean move existing blocks '
        'to a preferred valid slot where possible.\n\n'
        'Also silently detect whether the request states:\n'
        '- a specific day: today, tomorrow, Monday-Sunday, or a clear date. '
        'If no day is stated, use the currently viewed day '
        '($selectedDayKey).\n'
        '- a specific Chemistry chapter/subtopic/subject. If none is stated, '
        'reuse the affected day\'s current chapter/subtopic when changing '
        'time, or choose a sensible Chemistry block from the catalogue when '
        'adding.\n'
        '- a specific time preference. "Morning" means weekend slots before '
        '12:00 only; "night" or "evening" means 19:00-20:00 or 20:15-21:15. '
        '"Later" means the next valid slot after the device current time if '
        'the request refers to today; otherwise it means a later slot than '
        'the current block on the selected day.\n\n'
        'Rules:\n'
        '- If the request is ambiguous, vague, or does not clearly name a '
        'day other than $selectedDayKey, make the minimal safe change: only '
        'modify $selectedDayKey and include no other day in "changed_days".\n'
        '- Only modify a day other than $selectedDayKey if the student\'s '
        'request explicitly and unambiguously names or clearly implies that '
        'other day.\n'
        '- For "I want to study again later", add one extra block later on '
        'the selected day if an unused fixed slot exists; otherwise move the '
        'latest block later if possible.\n'
        '- For "I am busy today", return the selected day or today as an '
        'empty list, unless the request also gives a replacement time.\n'
        '- For "I don\'t want study at morning but I want study at night", '
        'remove morning blocks and replace them with night/evening slots. If '
        'the selected day is a weekend, use 15:00-16:00 as the latest '
        'available slot because weekday night slots are not valid on '
        'weekends.\n'
        '- If the requested change is impossible because no valid fixed slot '
        'exists, return {"changed_days":{},"message":"..."} with one short '
        'sentence explaining what cannot be changed.\n'
        '- "changed_days" must contain ONLY the day key(s) you actually '
        'changed. Never include a day whose blocks are unchanged, even to '
        'echo them back.\n'
        '- For each day you include, return its FULL replacement list of '
        'blocks (not a partial diff) - e.g. removing a block means '
        'returning the remaining blocks only; adding time means returning '
        'the existing blocks plus the new one.\n'
        '- Each block must still use one of the fixed time slots for that '
        'day type (weekday: $weekdaySlots; weekend: $weekendSlots) and one '
        'chapter/subtopic pair from the Chemistry Form 4 syllabus.\n'
        '- "message" is exactly one short, friendly sentence confirming '
        'what changed, to show the student directly.\n\n'
        'Return only valid JSON, no markdown fences, no commentary, with '
        'exactly this schema: {"changed_days":{"$selectedDayKey":[{'
        '"chapterNumber":0,"chapterTitle":"...","subtopic":"...",'
        '"startTime":"19:00","endTime":"20:00"}]},"message":"..."}.';
  }

  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
