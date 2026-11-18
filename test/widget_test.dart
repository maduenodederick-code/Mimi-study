import 'package:flutter_test/flutter_test.dart';
import 'package:mimi_study/main.dart';

void main() {
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

    await tester.tap(find.text('番茄钟'));
    await tester.pumpAndSettle();

    expect(find.text('番茄专注'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
  });
}
