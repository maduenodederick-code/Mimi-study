import 'package:flutter/material.dart';

const _ink = Color(0xFF45383B);
const _muted = Color(0xFF927F83);
const _pink = Color(0xFFF4A9B8);
const _cream = Color(0xFFFFFAF7);
const _line = Color(0xFFF3E9E7);

class ChatMessage {
  ChatMessage(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage('你好呀！我是 Mimi 🐈\n我可以陪你整理学习目标、拆解复习任务，也可以帮你梳理知识点。', fromUser: false),
  ];

  final List<String> _suggestions = [
    '帮我制定今天的学习计划',
    '把一个大任务拆成小步骤',
    '给我一个 25 分钟复习安排',
  ];

  void _send([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, fromUser: true));
      _messages.add(ChatMessage(
        '我已经收到你的问题啦。当前是聊天界面预览版，AI 服务还没有连接，所以暂时不能生成真实回答。接入安全的服务端接口后，我就能根据你的学习内容认真帮你分析。', 
        fromUser: false,
      ));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: Color(0xFFFFE8ED), shape: BoxShape.circle),
                child: const Center(child: Text('🐈', style: TextStyle(fontSize: 27))),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mimi AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink)),
                    SizedBox(height: 2),
                    Text('你的学习搭子', style: TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(20)),
                child: const Text('预览版', style: TextStyle(fontSize: 11, color: Color(0xFF9A705D), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: const Color(0xFFFFF3E9), borderRadius: BorderRadius.circular(13)),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 17, color: Color(0xFFAD806B)),
              SizedBox(width: 8),
              Expanded(child: Text('当前为界面预览，尚未连接 AI 服务。你的消息只用于展示交互，不会获得真实 AI 答复。', style: TextStyle(fontSize: 11, height: 1.45, color: Color(0xFF8F6D5D)))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _MessageBubble(message: _messages[index]),
          ),
        ),
        if (_messages.length == 1)
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                label: Text(_suggestions[index], style: const TextStyle(fontSize: 11, color: _ink)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: _line),
                onPressed: () => _send(_suggestions[index]),
              ),
            ),
          ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '输入你想讨论的学习问题…',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFB6A8AB)),
                      filled: true,
                      fillColor: _cream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                IconButton.filled(
                  onPressed: _send,
                  style: IconButton.styleFrom(backgroundColor: _pink, foregroundColor: _ink),
                  icon: const Icon(Icons.arrow_upward_rounded),
                  tooltip: '发送',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.fromUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: user ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!user) ...[
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFFFFE8ED), child: Text('🐈', style: TextStyle(fontSize: 17))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: user ? const Color(0xFFFFE5EA) : Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: user ? null : Border.all(color: _line),
              ),
              child: Text(message.text, style: const TextStyle(fontSize: 13, height: 1.55, color: _ink)),
            ),
          ),
        ],
      ),
    );
  }
}
