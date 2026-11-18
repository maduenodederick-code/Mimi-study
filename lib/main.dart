import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'ai_assistant_page.dart';
import 'app_storage.dart';
import 'knowledge_base_page.dart';

void main() => runApp(const MimiStudyApp());
const blush = Color(0xFFF4A9B8), cream = Color(0xFFFFFAF7), ink = Color(0xFF45383B), muted = Color(0xFF927F83), line = Color(0xFFF3E9E7);

class MimiStudyApp extends StatelessWidget {
  const MimiStudyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Mimi Study', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: cream, colorScheme: ColorScheme.fromSeed(seedColor: blush, surface: cream)),
    home: const MainShell());
}

class StudyTask {
  StudyTask(this.title, {this.completed = false});
  final String title;
  bool completed;

  Map<String, dynamic> toJson() => {'title': title, 'completed': completed};
  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
    json['title'] as String? ?? '',
    completed: json['completed'] as bool? ?? false,
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  int focusMinutes = 0;
  final tasks = <StudyTask>[];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final results = await Future.wait([
      AppStorage.loadTasks(),
      AppStorage.loadFocusMinutes(),
    ]);
    if (!mounted) return;
    setState(() {
      tasks
        ..clear()
        ..addAll((results[0] as List<Map<String, dynamic>>).map(StudyTask.fromJson));
      focusMinutes = results[1] as int;
    });
  }

  Future<void> _saveTasks() => AppStorage.saveTasks(tasks.map((task) => task.toJson()).toList());

  void _taskChanged() {
    setState(() {});
    _saveTasks();
  }

  void _recordFocusSession() {
    setState(() => focusMinutes += 25);
    AppStorage.saveFocusMinutes(focusMinutes);
  }

  Future<void> addTask() async {
    final input = TextEditingController();
    final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      backgroundColor: Colors.white, title: const Text('添加学习任务'),
      content: TextField(controller: input, autofocus: true, maxLength: 60, decoration: const InputDecoration(hintText: '例如：复习药物分析第三章'),
        onSubmitted: (v) => Navigator.pop(context, v.trim())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: () => Navigator.pop(context, input.text.trim()), child: const Text('添加')),
      ]));
    input.dispose();
    if (value != null && value.isNotEmpty) {
      setState(() => tasks.insert(0, StudyTask(value)));
      await _saveTasks();
    }
  }

  void openTimer() => showDialog(context: context, builder: (_) => PomodoroDialog(onFocusCompleted: _recordFocusSession));

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(tasks: tasks, addTask: addTask, openTimer: openTimer, refresh: _taskChanged, goPlan: () => setState(() => tab = 1), focusMinutes: focusMinutes),
      PlanPage(tasks: tasks, addTask: addTask, refresh: _taskChanged),
      const AiAssistantPage(),
      const KnowledgeBasePage(),
      const PlaceholderPage(title: '我的', subtitle: '查看学习记录与个人设置。', icon: Icons.person_rounded),
    ];
    return Scaffold(body: SafeArea(child: pages[tab]), bottomNavigationBar: NavigationBar(
      height: 68, selectedIndex: tab, backgroundColor: Colors.white, indicatorColor: const Color(0xFFFFE5EA),
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_rounded), label: '首页'),
        NavigationDestination(icon: Icon(Icons.event_note_rounded), label: '计划'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'AI 助手'),
        NavigationDestination(icon: Icon(Icons.library_books_rounded), label: '知识库'),
        NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: '我的'),
      ]));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.tasks, required this.addTask, required this.openTimer, required this.refresh, required this.goPlan, required this.focusMinutes});
  final List<StudyTask> tasks;
  final VoidCallback addTask, openTimer, goPlan, refresh;
  final int focusMinutes;

  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.completed).length;
    final pending = tasks.length - done;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mimi Study', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
          SizedBox(height: 4), Text('今天也向目标靠近一点点', style: TextStyle(fontSize: 13, color: muted)),
        ])),
        const CircleAvatar(backgroundColor: Color(0xFFFFE8ED), child: Icon(Icons.notifications_none_rounded, color: Color(0xFFB86F80))),
      ]),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFE8ED), Color(0xFFFFF1E8)]), borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('早上好，学习者！', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF654B52))),
            SizedBox(height: 8), Text('给今天设定一个小目标，\n慢慢积累，也会有大收获。', style: TextStyle(height: 1.5, color: Color(0xFF876D74))),
          ])),
          const CircleAvatar(radius: 38, backgroundColor: cream, child: Text('🐈', style: TextStyle(fontSize: 42))),
        ])),
      const SizedBox(height: 22), const Heading('今日概览'), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: MetricCard(icon: Icons.check_circle_outline_rounded, title: '待完成任务', value: pending.toString(), detail: '已完成 $done 项', tint: const Color(0xFFEAF3FF))),
        const SizedBox(width: 12),
        Expanded(child: MetricCard(icon: Icons.local_fire_department_rounded, title: '累计专注', value: '$focusMinutes 分钟', detail: '完成专注后自动记录', tint: const Color(0xFFFFF0E6))),
      ]),
      const SizedBox(height: 22), const Heading('快速开始'), const SizedBox(height: 12),
      Row(children: [
        Expanded(child: QuickAction(icon: Icons.timer_outlined, title: '番茄钟', tint: const Color(0xFFFFE8ED), onTap: openTimer)),
        const SizedBox(width: 10),
        Expanded(child: QuickAction(icon: Icons.add_task_rounded, title: '添加任务', tint: const Color(0xFFEAF3FF), onTap: addTask)),
        const SizedBox(width: 10),
        const Expanded(child: QuickAction(icon: Icons.edit_note_rounded, title: '记笔记', tint: Color(0xFFEAF5EA))),
      ]),
      const SizedBox(height: 22),
      Row(children: [const Heading('今日学习计划'), const Spacer(), TextButton(onPressed: goPlan, child: const Text('查看全部'))]),
      const SizedBox(height: 8),
      if (tasks.isEmpty)
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
          child: Row(children: [
            const Icon(Icons.spa_outlined, color: Color(0xFFD99AA7)), const SizedBox(width: 10),
            const Expanded(child: Text('还没有安排今天的任务\n添加一个小目标，开启学习吧！', style: TextStyle(height: 1.5, color: muted))),
            TextButton(onPressed: addTask, child: const Text('添加')),
          ]))
      else
        ...tasks.take(3).map((t) => TaskRow(task: t, onChanged: refresh)),
    ]);
  }
}

class PlanPage extends StatelessWidget {
  const PlanPage({super.key, required this.tasks, required this.addTask, required this.refresh});
  final List<StudyTask> tasks;
  final VoidCallback addTask, refresh;
  @override
  Widget build(BuildContext context) {
    final done = tasks.where((t) => t.completed).length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('学习计划', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 6), const Text('把大目标拆成每天可以完成的小任务。', style: TextStyle(color: muted)),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFE8ED), Color(0xFFFFF1E8)]), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('今日完成进度', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF765A62))),
          const SizedBox(height: 10),
          Text('$done / ' + tasks.length.toString() + ' 项任务', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: tasks.isEmpty ? 0 : done / tasks.length, minHeight: 8, backgroundColor: Colors.white, color: blush)),
        ])),
      const SizedBox(height: 22),
      Row(children: [const Heading('今日任务'), const Spacer(), Text(tasks.length.toString() + ' 项', style: const TextStyle(color: muted))]),
      const SizedBox(height: 12),
      if (tasks.isEmpty)
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: line)),
          child: const Column(children: [Icon(Icons.checklist_rounded, size: 42, color: Color(0xFFD99AA7)), SizedBox(height: 10), Text('还没有学习任务', style: TextStyle(fontWeight: FontWeight.w700, color: ink)), SizedBox(height: 4), Text('添加第一项任务，开始安排今天吧。', style: TextStyle(color: muted))]))
      else
        ...tasks.map((t) => TaskRow(task: t, onChanged: refresh)),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: addTask, icon: const Icon(Icons.add_rounded), label: const Text('添加学习任务'), style: FilledButton.styleFrom(backgroundColor: blush, foregroundColor: ink, padding: const EdgeInsets.symmetric(vertical: 14))),
    ]);
  }
}

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, required this.onChanged});
  final StudyTask task;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
    child: Row(children: [
      Checkbox(value: task.completed, activeColor: blush, onChanged: (v) { task.completed = v ?? false; onChanged(); }),
      Expanded(child: Text(task.title, style: TextStyle(color: task.completed ? muted : ink, decoration: task.completed ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600))),
    ]));
}

class PomodoroDialog extends StatefulWidget {
  const PomodoroDialog({super.key, required this.onFocusCompleted});
  final VoidCallback onFocusCompleted;
  @override
  State<PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<PomodoroDialog> {
  int selected = 25, remaining = 1500;
  bool running = false;
  Timer? timer;
  void choose(int minutes) { timer?.cancel(); setState(() { selected = minutes; remaining = minutes * 60; running = false; }); }
  void reset() { timer?.cancel(); setState(() { remaining = selected * 60; running = false; }); }
  void toggle() {
    if (running) { timer?.cancel(); setState(() => running = false); return; }
    if (remaining == 0) remaining = selected * 60;
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (remaining <= 1) {
        t.cancel(); setState(() { remaining = 0; running = false; });
        if (selected == 25) widget.onFocusCompleted();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('专注时间结束，休息一下吧！')));
      } else { setState(() => remaining--); }
    });
  }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final time = (remaining ~/ 60).toString().padLeft(2, '0') + ':' + (remaining % 60).toString().padLeft(2, '0');
    return Dialog(backgroundColor: cream, child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [const Expanded(child: Text('番茄专注', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
      const SizedBox(height: 10),
      Container(width: 205, height: 205, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFFFE5EA), width: 9)),
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(width: 185, height: 185, child: CircularProgressIndicator(value: 1 - remaining / (selected * 60), strokeWidth: 8, backgroundColor: const Color(0xFFFFF0F2), color: blush)),
          Column(mainAxisSize: MainAxisSize.min, children: [const Text('保持专注', style: TextStyle(color: muted)), const SizedBox(height: 5), Text(time, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: ink, fontFeatures: [FontFeature.tabularFigures()])), const Text('🐈 Mimi 陪着你', style: TextStyle(color: muted, fontSize: 12))]),
        ])),
      const SizedBox(height: 18),
      Wrap(spacing: 8, children: [25, 5, 15].map((m) => ChoiceChip(label: Text(m == 25 ? '专注 25 分钟' : '休息 $m 分钟'), selected: selected == m, onSelected: (_) => choose(m), selectedColor: const Color(0xFFFFE5EA))).toList()),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.refresh_rounded), label: const Text('重置'))),
        const SizedBox(width: 10),
        Expanded(child: FilledButton.icon(onPressed: toggle, icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded), label: Text(running ? '暂停' : '开始'), style: FilledButton.styleFrom(backgroundColor: blush, foregroundColor: ink))),
      ]),
    ])));
  }
}

class Heading extends StatelessWidget {
  const Heading(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink));
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.icon, required this.title, required this.value, required this.detail, required this.tint});
  final IconData icon; final String title, value, detail; final Color tint;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: const Color(0xFF98717A))),
      const SizedBox(height: 10), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink)),
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
      const SizedBox(height: 4), Text(detail, style: const TextStyle(fontSize: 10, color: muted)),
    ]));
}

class QuickAction extends StatelessWidget {
  const QuickAction({super.key, required this.icon, required this.title, required this.tint, this.onTap});
  final IconData icon; final String title; final Color tint; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18),
    child: Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: line)),
      child: Column(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF98717A))), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink))]))));
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, required this.subtitle, required this.icon});
  final String title, subtitle; final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 82, height: 82, decoration: const BoxDecoration(color: Color(0xFFFFE8ED), shape: BoxShape.circle), child: Icon(icon, size: 38, color: const Color(0xFFB87988))),
    const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink)),
    const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(height: 1.5, color: muted)),
    const SizedBox(height: 16), const Text('这个模块正在搭建中', style: TextStyle(fontSize: 12, color: Color(0xFFB87988))),
  ])));
}
