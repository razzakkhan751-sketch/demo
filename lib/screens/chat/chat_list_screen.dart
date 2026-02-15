// ──────────────────────────────────────────────────────────
// ChatListScreen — Role-based chat list
// Students: see only their own chats
// Teachers/Admins: see all platform chats
// ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_room.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firebaseUser = authService.currentUser;
    final userModel = authService.userModel;
    final chatService = ChatService();
    final theme = Theme.of(context);

    if (firebaseUser == null || userModel == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to access chats')),
      );
    }

    final role = userModel.role;
    final isStudentRole = role == 'student';

    // Students see only their chats; teachers/admins see all
    final Stream<List<ChatRoom>> chatStream = isStudentRole
        ? chatService.getStudentChats(firebaseUser.uid)
        : chatService.getAllChats();

    return Scaffold(
      appBar: AppBar(
        title: Text(isStudentRole ? 'My Messages' : 'All Messages'),
        centerTitle: true,
        actions: [
          if (role == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin view — all chats visible',
              onPressed: () {},
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showNewChatDialog(context, firebaseUser.uid, userModel.name, role),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('New Chat'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error loading chats',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text('${snapshot.error}', style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isStudentRole
                        ? 'Start a conversation with a teacher'
                        : 'Chats will appear here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final otherName = room.getOtherParticipantName(firebaseUser.uid);
              final otherRole = room.getOtherParticipantRole(firebaseUser.uid);
              final initial = otherName.isNotEmpty
                  ? otherName[0].toUpperCase()
                  : '?';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _roleColor(otherRole),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherName.isNotEmpty ? otherName : 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _roleColor(otherRole).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        otherRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _roleColor(otherRole),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  room.lastMessage.isNotEmpty
                      ? room.lastMessage
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        roomId: room.id,
                        otherUserName: otherName,
                        otherUserRole: otherRole,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.deepPurple;
      case 'teacher':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  void _showNewChatDialog(
    BuildContext context,
    String currentUserId,
    String currentUserName,
    String currentUserRole,
  ) async {
    final chatService = ChatService();
    final users = await chatService.getAvailableUsers(
      currentUserId: currentUserId,
      currentUserRole: currentUserRole,
    );

    if (!context.mounted) return;

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users available to chat with')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Start New Chat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                final name = u['name'] ?? u['email'] ?? 'User';
                final role = u['role'] ?? 'student';
                final uid = u['uid'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _roleColor(role),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text(role.toString().toUpperCase()),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final roomId = await chatService.createPrivateChat(
                      userId: currentUserId,
                      userName: currentUserName,
                      userRole: currentUserRole,
                      otherUserId: uid,
                      otherUserName: name,
                      otherUserRole: role,
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            roomId: roomId,
                            otherUserName: name,
                            otherUserRole: role,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
