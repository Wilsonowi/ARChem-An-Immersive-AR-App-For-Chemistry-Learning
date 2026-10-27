// One-time / re-run-on-content-change dev script.
// Reads rag.json, splits each topic into a core-concept chunk plus one chunk
// per table/list, embeds each chunk with Gemini, and upserts them into the
// Supabase `chemistry_knowledge` table (see supabase/migrations/0001_chemistry_knowledge_rag.sql).
//
// Usage (from the project root):
//   dart run tool/seed_knowledge.dart --service-key=<SUPABASE_SERVICE_ROLE_KEY>
// or set the SUPABASE_SERVICE_ROLE_KEY environment variable instead of the flag.
//
// The service-role key bypasses RLS and must never be committed or shipped in
// the app - it is only used here, once, from your machine.

import 'dart:convert';
import 'dart:io';

const _supabaseUrl = 'https://ysqpaxwpszyldqhevcfo.supabase.co';

// Same key already hardcoded in lib/services/gemini_service.dart.
const _geminiApiKey = 'AIzaSyDZm6AcqgAbd0BuWBZUOxcWaLX2-qhm7GY';
const _embedUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=$_geminiApiKey';

Future<void> main(List<String> args) async {
  final serviceKey = _readServiceKey(args);
  if (serviceKey == null) {
    stderr.writeln(
      'Missing service role key. Pass --service-key=... or set '
      'SUPABASE_SERVICE_ROLE_KEY.',
    );
    exit(1);
  }

  final jsonFile = File('rag.json');
  if (!jsonFile.existsSync()) {
    stderr.writeln('rag.json not found in project root.');
    exit(1);
  }

  final entries = jsonDecode(await jsonFile.readAsString()) as List<dynamic>;
  final chunks = <Map<String, dynamic>>[];
  for (final entry in entries.cast<Map<String, dynamic>>()) {
    chunks.addAll(_chunksForEntry(entry));
  }

  print('Prepared ${chunks.length} chunks from ${entries.length} topics.');

  print('Clearing existing rows in chemistry_knowledge...');
  await _deleteAllRows(serviceKey);

  final rows = <Map<String, dynamic>>[];
  for (var i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    final embedding = await _embed(chunk['content'] as String);
    rows.add({...chunk, 'embedding': embedding});
    stdout.write('\rEmbedded ${i + 1}/${chunks.length}');
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
  print('');

  print('Inserting ${rows.length} rows into Supabase...');
  const batchSize = 20;
  for (var i = 0; i < rows.length; i += batchSize) {
    final batch = rows.sublist(i, (i + batchSize).clamp(0, rows.length));
    await _insertBatch(serviceKey, batch);
    print('Inserted ${(i + batch.length).clamp(0, rows.length)}/${rows.length}');
  }

  print('Done.');
}

String? _readServiceKey(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--service-key=')) {
      return arg.substring('--service-key='.length);
    }
  }
  return Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
}

List<Map<String, dynamic>> _chunksForEntry(Map<String, dynamic> entry) {
  final chapterNumber = int.parse(entry['chapter_number'] as String);
  final chapterTitle = entry['chapter_title'] as String;
  final topicNumber = entry['topic_number'] as String;
  final topicTitle = entry['topic_title'] as String;
  final sourceId = entry['id'] as String;

  final header = '$chapterTitle\nTopic $topicNumber: $topicTitle';

  final chunks = <Map<String, dynamic>>[];

  final coreBuffer = StringBuffer()
    ..writeln(header)
    ..writeln()
    ..writeln('Definition: ${entry['definition']}')
    ..writeln('Key principle: ${entry['key_principle']}');
  final formula = entry['formula'] as String?;
  if (formula != null && formula.trim().isNotEmpty && formula != 'Not Applicable') {
    coreBuffer.writeln('Formula: $formula');
  }
  final variables = entry['variables'] as String?;
  if (variables != null && variables.trim().isNotEmpty && variables != 'Not Applicable') {
    coreBuffer.writeln('Variables: $variables');
  }

  chunks.add({
    'source_id': '${sourceId}_core',
    'chapter_number': chapterNumber,
    'chapter_title': chapterTitle,
    'topic_number': topicNumber,
    'topic_title': topicTitle,
    'section': 'Core Concept',
    'content': coreBuffer.toString().trim(),
  });

  final essentialData = (entry['essential_data'] as List<dynamic>?) ?? const [];
  var blockIndex = 0;
  String? pendingNote;

  for (final raw in essentialData) {
    final block = raw as Map<String, dynamic>;
    final type = block['type'] as String;

    if (type == 'note') {
      pendingNote = block['text'] as String?;
      continue;
    }

    final title = block['title'] as String? ?? '';
    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln();

    if (type == 'table') {
      final headers = (block['headers'] as List<dynamic>).cast<String>();
      final rows = (block['rows'] as List<dynamic>).cast<List<dynamic>>();
      buffer.writeln('Table: $title');
      for (final row in rows) {
        final cells = row.cast<String>();
        final pairs = <String>[];
        for (var i = 0; i < headers.length && i < cells.length; i++) {
          pairs.add('${headers[i]}: ${cells[i]}');
        }
        buffer.writeln(pairs.join(' | '));
      }
    } else if (type == 'list') {
      final items = (block['items'] as List<dynamic>).cast<String>();
      buffer.writeln('List: $title');
      for (final item in items) {
        buffer.writeln('- $item');
      }
    } else {
      continue;
    }

    if (pendingNote != null) {
      buffer.writeln();
      buffer.writeln('Note: $pendingNote');
      pendingNote = null;
    }

    chunks.add({
      'source_id': '${sourceId}_block_$blockIndex',
      'chapter_number': chapterNumber,
      'chapter_title': chapterTitle,
      'topic_number': topicNumber,
      'topic_title': topicTitle,
      'section': title.isEmpty ? 'Reference Data' : title,
      'content': buffer.toString().trim(),
    });
    blockIndex++;
  }

  return chunks;
}

Future<List<double>> _embed(String text) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(_embedUrl));
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.add(
      utf8.encode(
        jsonEncode({
          'model': 'models/gemini-embedding-001',
          'content': {
            'parts': [
              {'text': text},
            ],
          },
          'taskType': 'RETRIEVAL_DOCUMENT',
          'outputDimensionality': 768,
        }),
      ),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Gemini embed error ${response.statusCode}: $body');
    }
    final data = jsonDecode(body) as Map<String, dynamic>;
    final values = (data['embedding']?['values'] as List<dynamic>).cast<num>();
    return values.map((v) => v.toDouble()).toList();
  } finally {
    client.close();
  }
}

Future<void> _deleteAllRows(String serviceKey) async {
  final client = HttpClient();
  try {
    final request = await client.deleteUrl(
      Uri.parse('$_supabaseUrl/rest/v1/chemistry_knowledge?id=gt.0'),
    );
    _setServiceHeaders(request, serviceKey);
    final response = await request.close();
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Failed to clear table: ${response.statusCode}');
    }
  } finally {
    client.close();
  }
}

Future<void> _insertBatch(
  String serviceKey,
  List<Map<String, dynamic>> batch,
) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$_supabaseUrl/rest/v1/chemistry_knowledge'),
    );
    _setServiceHeaders(request, serviceKey);
    request.add(utf8.encode(jsonEncode(batch)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Insert failed ${response.statusCode}: $body');
    }
  } finally {
    client.close();
  }
}

void _setServiceHeaders(HttpClientRequest request, String serviceKey) {
  request.headers
    ..set('apikey', serviceKey)
    ..set('Authorization', 'Bearer $serviceKey')
    ..set('Content-Type', 'application/json; charset=utf-8')
    ..set('Prefer', 'return=minimal');
}
