import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimi_study/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Mimi Study opens the home dashboard', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());

    expect(find.text('Mimi Study'), findsOneWidget);
    expect(find.text('今日概览'), findsOneWidget);
    expect(find.text('快速开始'), findsOneWidget);
  });

  testWidgets('bottom navigation opens the study plan', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());

    await tester.tap(find.text('计划'));
    await tester.pumpAndSettle();

    expect(find.text('学习计划'), findsOneWidget);
    expect(find.text('添加学习任务'), findsOneWidget);
  });

  testWidgets('quick action opens the pomodoro timer', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());

    final pomodoroAction = find.text('番茄钟');
    await tester.ensureVisible(pomodoroAction);
    await tester.pumpAndSettle();
    await tester.tap(pomodoroAction);
    await tester.pumpAndSettle();

    expect(find.text('番茄专注'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('AI assistant opens the chat preview', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());

    await tester.tap(find.text('AI 助手'));
    await tester.pumpAndSettle();

    expect(find.text('Mimi AI'), findsOneWidget);
    expect(find.text('预览版'), findsOneWidget);
    expect(find.textContaining('尚未连接 AI 服务'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });


  testWidgets('knowledge base can create and search a note', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());

    await tester.tap(find.text('知识库'));
    await tester.pumpAndSettle();

    expect(find.text('还没有笔记'), findsOneWidget);
    await tester.tap(find.text('新建笔记'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '笔记标题'), '药物分析重点');
    await tester.enterText(find.widgetWithText(TextField, '笔记内容'), '液相色谱的基本原理');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('药物分析重点'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '色谱');
    await tester.pumpAndSettle();
    expect(find.text('药物分析重点'), findsOneWidget);
  });

  testWidgets('profile shows learning statistics and settings', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('学习统计'), findsOneWidget);
    expect(find.text('任务完成率'), findsOneWidget);
    expect(find.text('累计专注'), findsOneWidget);
    await tester.dragUntilVisible(find.text('最近 7 天专注'), find.byType(ListView), const Offset(0, -300));
    expect(find.text('最近 7 天专注'), findsOneWidget);
    await tester.dragUntilVisible(find.text('数据存储'), find.byType(ListView), const Offset(0, -300));
    expect(find.text('数据存储'), findsOneWidget);
    await tester.dragUntilVisible(find.text('清空所有学习数据'), find.byType(ListView), const Offset(0, -300));
    expect(find.text('清空所有学习数据'), findsOneWidget);
  });

  testWidgets('profile requires confirmation before clearing data', (tester) async {
    await tester.pumpWidget(const MimiStudyApp());
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('清空所有学习数据'), find.byType(ListView), const Offset(0, -300));
    await tester.tap(find.text('清空所有学习数据'));
    await tester.pumpAndSettle();
    expect(find.text('清空所有学习数据？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('清空所有学习数据？'), findsNothing);
  });
}
