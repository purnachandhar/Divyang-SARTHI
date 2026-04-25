import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteChatDetailView extends StatefulWidget {
  const InstituteChatDetailView({super.key});

  @override
  State<InstituteChatDetailView> createState() =>
      _InstituteChatDetailViewState();
}

class _InstituteChatDetailViewState extends State<InstituteChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> userData = Get.arguments ?? {};

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello, how is the student performing in class?',
      'isMe': false,
      'time': '10:30 AM'
    },
    {
      'text': 'The student is doing great! Very active in activities.',
      'isMe': true,
      'time': '10:32 AM'
    },
    {
      'text': 'That is wonderful to hear. Thank you.',
      'isMe': false,
      'time': '10:35 AM'
    },
  ].obs;

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    _messages.add({
      'text': _messageController.text.trim(),
      'isMe': true,
      'time': 'Just now',
    });

    _messageController.clear();

    // Auto-scroll to bottom after message
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate auto-reply
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _messages.add({
        'text': 'Got it! I will update the records.',
        'isMe': false,
        'time': 'Just now',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _ChatBubble(
                      message: msg['text'],
                      isMe: msg['isMe'],
                      time: msg['time'],
                    );
                  },
                )),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool isProf = userData['image'] == 'prof';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  isProf ? Icons.psychology : Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'] ?? 'User',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Online',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.videocam_outlined, color: Colors.white),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.call_outlined, color: Colors.white),
              onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration:
                BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: IconButton(
                icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                onPressed: () {}),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          IconButton(
              icon:
                  const Icon(Icons.sentiment_satisfied_alt, color: Colors.grey),
              onPressed: () {}),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const _ChatBubble(
      {required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                  color: isMe ? Colors.white70 : AppTheme.textSecondary,
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
