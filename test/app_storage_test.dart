import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mimi_study/app_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('study tasks and focus time survive app reloads', () async {
    final tasks = [
      {'title': '复习药物分析', 'completed': true},
      {'title': '整理课堂笔记', 'completed': false},
    ];

    await AppStorage.saveTasks(tasks);
    await AppStorage.saveFocusMinutes(50);

    expect(await AppStorage.loadTasks(), tasks);
    expect(await AppStorage.loadFocusMinutes(), 50);
  });

  test('daily focus sessions are stored locally and cleared with all data', () async {
    final sessions = [
      {'date': '2026-11-19', 'minutes': 50, 'sessions': 2},
    ];
    await AppStorage.saveFocusSessions(sessions);
    expect(await AppStorage.loadFocusSessions(), sessions);

    await AppStorage.clearAll();
    expect(await AppStorage.loadFocusSessions(), isEmpty);
  });

  test('knowledge notes are stored locally', () async {
    final notes = [
      {'id': 'note-1', 'title': '色谱法', 'body': '分离分析方法'},
    ];

    await AppStorage.saveNotes(notes);

    expect(await AppStorage.loadNotes(), notes);
  });
}
