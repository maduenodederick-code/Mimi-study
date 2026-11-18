import 'package:flutter/material.dart';

import 'app_storage.dart';

const _ink = Color(0xFF45383B);
const _muted = Color(0xFF927F83);
const _pink = Color(0xFFF4A9B8);
const _line = Color(0xFFF3E9E7);

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({super.key});

  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  final List<Map<String, dynamic>> _notes = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final saved = await AppStorage.loadNotes();
    if (!mounted) return;
    setState(() {
      _notes
        ..clear()
        ..addAll(saved);
      _loading = false;
    });
  }

  Future<void> _saveNotes() => AppStorage.saveNotes(_notes);

  Future<void> _editNote({Map<String, dynamic>? note}) async {
    final titleController = TextEditingController(text: note?['title'] as String? ?? '');
    final bodyController = TextEditingController(text: note?['body'] as String? ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? '新建笔记' : '编辑笔记'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                maxLength: 40,
                decoration: const InputDecoration(labelText: '笔记标题', hintText: '例如：色谱法重点整理'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyController,
                minLines: 4,
                maxLines: 8,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: '笔记内容',
                  hintText: '记录知识点、公式或复习心得…',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, {
              'title': titleController.text.trim(),
              'body': bodyController.text.trim(),
            }),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    titleController.dispose();
    bodyController.dispose();

    if (result == null || result['title']!.isEmpty) return;
    setState(() {
      if (note == null) {
        _notes.insert(0, {
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'title': result['title'],
          'body': result['body'],
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        note['title'] = result['title'];
        note['body'] = result['body'];
        note['updatedAt'] = DateTime.now().toIso8601String();
      }
    });
    await _saveNotes();
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    setState(() => _notes.remove(note));
    await _saveNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleNotes = _notes.where((note) {
      final title = (note['title'] as String? ?? '').toLowerCase();
      final body = (note['body'] as String? ?? '').toLowerCase();
      return title.contains(query) || body.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('知识库', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink)),
                    SizedBox(height: 4),
                    Text('把学过的内容整理成自己的知识资产。', style: TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () => _editNote(),
                style: IconButton.styleFrom(backgroundColor: _pink, foregroundColor: _ink),
                icon: const Icon(Icons.add_rounded),
                tooltip: '新建笔记',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: _muted),
              hintText: '搜索标题或笔记内容',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _line)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _pink))
              : visibleNotes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFFD99AA7)),
                            const SizedBox(height: 12),
                            Text(query.isEmpty ? '还没有笔记' : '没有找到相关笔记', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink)),
                            const SizedBox(height: 5),
                            Text(query.isEmpty ? '点击右上角 +，记录第一个知识点。' : '试试更短的关键词。', style: const TextStyle(color: _muted, fontSize: 12)),
                            if (query.isEmpty) ...[
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: () => _editNote(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('新建笔记'),
                                style: FilledButton.styleFrom(backgroundColor: _pink, foregroundColor: _ink),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: visibleNotes.length,
                      itemBuilder: (context, index) {
                        final note = visibleNotes[index];
                        final body = note['body'] as String? ?? '';
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                            side: const BorderSide(color: _line),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: const Color(0xFFFFE8ED), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.sticky_note_2_outlined, color: Color(0xFFB87988)),
                            ),
                            title: Text(note['title'] as String? ?? '未命名笔记', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(body.isEmpty ? '暂无正文' : body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(height: 1.4, color: _muted, fontSize: 12)),
                            ),
                            onTap: () => _editNote(note: note),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editNote(note: note);
                                if (value == 'delete') _deleteNote(note);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('编辑')),
                                PopupMenuItem(value: 'delete', child: Text('删除')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
