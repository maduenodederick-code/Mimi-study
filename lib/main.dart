import 'package:flutter/material.dart';

void main() {
  runApp(const MimiStudyApp());
}

class MimiStudyApp extends StatelessWidget {
  const MimiStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blush = Color(0xFFF4A9B8);
    return MaterialApp(
      title: 'Mimi Study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFAF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blush,
          surface: const Color(0xFFFFFAF7),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  static const pages = [
    HomePage(),
    PlaceholderPage(title: '学习计划', subtitle: '把目标拆解成每天的小进步。', icon: Icons.calendar_month_rounded),
    PlaceholderPage(title: 'AI 助手', subtitle: '让 Mimi 陪你规划、答疑和复习。', icon: Icons.auto_awesome_rounded),
    PlaceholderPage(title: '知识库', subtitle: '集中整理课程、笔记与知识卡片。', icon: Icons.menu_book_rounded),
    PlaceholderPage(title: '我的', subtitle: '查看学习记录与个人设置。', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE5EA),
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '首页'),
          NavigationDestination(icon: Icon(Icons.event_note_rounded), label: '计划'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'AI 助手'),
          NavigationDestination(icon: Icon(Icons.library_books_rounded), label: '知识库'),
          NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: '我的'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mimi Study', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF45383B))),
                  SizedBox(height: 4),
                  Text('今天也向目标靠近一点点 ✨', style: TextStyle(fontSize: 13, color: Color(0xFF927F83))),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: Color(0xFFFFE8ED), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded, color: Color(0xFFB86F80)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFE8ED), Color(0xFFFFF1E8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('早上好，学习者！', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF654B52))),
                    SizedBox(height: 8),
                    Text('给今天设定一个小目标，\n慢慢积累，也会有大收获。', style: TextStyle(height: 1.5, color: Color(0xFF876D74))),
                  ],
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(color: Color(0xFFFFFAF7), shape: BoxShape.circle),
                child: const Center(child: Text('🐱', style: TextStyle(fontSize: 42))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading(title: '今日概览', action: '查看全部'),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: SummaryCard(icon: Icons.check_circle_outline_rounded, label: '待完成任务', value: '0', footnote: '安排今天的学习', tint: Color(0xFFEAF3FF))),
            SizedBox(width: 12),
            Expanded(child: SummaryCard(icon: Icons.local_fire_department_rounded, label: '连续打卡', value: '0 天', footnote: '从今天开始积累', tint: Color(0xFFFFF0E6))),
          ],
        ),
        const SizedBox(height: 22),
        const SectionHeading(title: '快速开始'),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: QuickAction(icon: Icons.timer_outlined, label: '番茄钟', color: Color(0xFFFFE8ED))),
            SizedBox(width: 10),
            Expanded(child: QuickAction(icon: Icons.add_task_rounded, label: '添加任务', color: Color(0xFFEAF3FF))),
            SizedBox(width: 10),
            Expanded(child: QuickAction(icon: Icons.edit_note_rounded, label: '记笔记', color: Color(0xFFEAF5EA))),
          ],
        ),
        const SizedBox(height: 22),
        const SectionHeading(title: '今日学习计划', action: '去计划'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3E9E7))),
          child: const Row(
            children: [
              Icon(Icons.spa_outlined, size: 28, color: Color(0xFFD99AA7)),
              SizedBox(width: 12),
              Expanded(child: Text('还没有安排今天的任务\n添加一个小目标，开启学习吧！', style: TextStyle(height: 1.5, color: Color(0xFF927F83)))),
              Icon(Icons.chevron_right_rounded, color: Color(0xFFB9A9AC)),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? action;
  const SectionHeading({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF45383B))),
        const Spacer(),
        if (action != null) Text(action!, style: const TextStyle(fontSize: 12, color: Color(0xFFB87988))),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String footnote;
  final Color tint;
  const SummaryCard({super.key, required this.icon, required this.label, required this.value, required this.footnote, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3E9E7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 19, color: const Color(0xFF98717A))),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF45383B))),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF69595D))),
        const SizedBox(height: 5),
        Text(footnote, style: const TextStyle(fontSize: 10, color: Color(0xFFAA999D))),
      ]),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const QuickAction({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF3E9E7))),
      child: Column(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF98717A))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF69595D))),
      ]),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 82, height: 82, decoration: const BoxDecoration(color: Color(0xFFFFE8ED), shape: BoxShape.circle), child: Icon(icon, size: 38, color: const Color(0xFFB87988))),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF45383B))),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(height: 1.5, color: Color(0xFF927F83))),
          const SizedBox(height: 16),
          const Text('这个模块正在搭建中', style: TextStyle(fontSize: 12, color: Color(0xFFB87988))),
        ]),
      ),
    );
  }
}
