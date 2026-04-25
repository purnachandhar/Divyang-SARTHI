import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteChatListView extends GetView<InstituteController> {
  const InstituteChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyChats = [
      {
        'name': 'Sandeep\'s Parent',
        'lastMessage': 'Hello, how is Sandeep performing?',
        'time': '10:30 AM',
        'unread': '2',
        'image': 'child'
      },
      {
        'name': 'Rahul (Educator)',
        'lastMessage': 'I have updated the attendance.',
        'time': '09:45 AM',
        'unread': '0',
        'image': 'prof'
      },
      {
        'name': 'Isha\'s Mother',
        'lastMessage': 'Thank you for the update.',
        'time': 'Yesterday',
        'unread': '0',
        'image': 'child'
      },
      {
        'name': 'Speech Therapist',
        'lastMessage': 'Session scheduled for tomorrow.',
        'time': 'Monday',
        'unread': '1',
        'image': 'prof'
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: dummyChats.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 80, endIndent: 20),
              itemBuilder: (context, index) {
                final chat = dummyChats[index];
                return _ChatTile(
                  chat: chat,
                  onTap: () => controller.goToChatDetail(chat),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Get.snackbar('New Chat', 'Search for a user to start a chat.'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.message_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
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
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Recent conversations',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, String> chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isUnread = chat['unread'] != '0';
    final bool isProf = chat['image'] == 'prof';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (isProf ? AppTheme.primaryColor : Colors.orange)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isProf ? Icons.psychology : Icons.person_outline,
                    color: isProf ? AppTheme.primaryColor : Colors.orange,
                    size: 30,
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name']!,
                        style: TextStyle(
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat['time']!,
                        style: TextStyle(
                          color: isUnread
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage']!,
                          style: TextStyle(
                            color: isUnread
                                ? Colors.black87
                                : AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat['unread']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
