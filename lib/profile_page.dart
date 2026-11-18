import 'package:flutter/material.dart';
import 'app_storage.dart';
import 'main.dart';

const _ink = Color(0xFF45383B);
const _muted = Color(0xFF927F83);
const _line = Color(0xFFF3E9E7);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.tasks, required this.focusMinutes, required this.onResetData});
  final List<StudyTask> tasks;
  final int focusMinutes;
  final Future<void> Function() onResetData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int noteCount = 0;
  bool loadingNotes = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await AppStorage.loadNotes();
    if (!mounted) return;
    setState(() { noteCount = notes.length; loadingNotes = false; });
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空所有学习数据？'),
        content: const Text('这将删除所有学习任务、知识库笔记和累计专注时长，且无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('确认清空')),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.onResetData();
    if (!mounted) return;
    setState(() => noteCount = 0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('学习数据已清空')));
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.tasks.where((task) => task.completed).length;
    final total = widget.tasks.length;
    final rate = total == 0 ? 0 : (completed / total * 100).round();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        const Text('我的', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 5),
        const Text('看看自己的学习积累与应用设置。', style: TextStyle(color: _muted, fontSize: 13)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFE8ED), Color(0xFFFFF1E8)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(children: [
            CircleAvatar(radius: 29, backgroundColor: Colors.white, child: Text('🐈', style: TextStyle(fontSize: 32))),
            SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mimi 学习者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
              SizedBox(height: 4),
              Text('每一点积累，都值得被记录。', style: TextStyle(color: _muted, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('学习统计', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.65,
          children: [
            _Stat(icon: Icons.checklist_rounded, label: '任务总数', value: '$total', detail: '已完成 $completed 项'),
            _Stat(icon: Icons.task_alt_rounded, label: '任务完成率', value: '$rate%', detail: '按当前任务计算'),
            _Stat(icon: Icons.timer_outlined, label: '累计专注', value: widget.focusMinutes.toString(), detail: '分钟'),
            _Stat(icon: Icons.menu_book_rounded, label: '知识库笔记', value: loadingNotes ? '…' : noteCount.toString(), detail: '已保存笔记'),
          ],
        ),
        const SizedBox(height: 24),
        const Text('应用设置', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 10),
        const _Setting(icon: Icons.palette_outlined, title: '外观主题', subtitle: '当前为 Mimi 粉色与奶油色主题'),
        const _Setting(icon: Icons.storage_outlined, title: '数据存储', subtitle: '学习任务、笔记和专注时长保存在当前设备'),
        const _Setting(icon: Icons.info_outline_rounded, title: '关于 Mimi Study', subtitle: '帮助你规划学习、专注和整理知识'),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('清空所有学习数据'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Color(0xFFE9B7B7))),
        ),
        const SizedBox(height: 8),
        const Text('清空操作会同时删除任务、笔记和累计专注记录。', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value, required this.detail});
  final IconData icon;
  final String label, value, detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [Icon(icon, size: 17, color: const Color(0xFFB87988)), const SizedBox(width: 6), Expanded(child: Text(label, style: const TextStyle(color: _muted, fontSize: 11)))]),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: _ink)),
      Text(detail, style: const TextStyle(fontSize: 10, color: _muted)),
    ]),
  );
}

class _Setting extends StatelessWidget {
  const _Setting({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: _line)),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFFB87988)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)),
    ),
  );
}
