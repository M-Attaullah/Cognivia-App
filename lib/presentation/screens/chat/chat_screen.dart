import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/real_chat_tile.dart';
import '../../../data/models/chat_model.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode? currentThemeMode;

  const ChatScreen({super.key, this.onThemeToggle, this.currentThemeMode});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatModel> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _searchController.addListener(_filterChats);
  }

  void _initializeChat() {
    // Initialize Firebase chat functionality
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Load user chats from Firebase
      chatProvider.loadUserChats(currentUser.uid);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _filteredChats = chatProvider.chats;
    } else {
      _filteredChats = chatProvider.chats.where((chat) {
        return chat.name.toLowerCase().contains(query) ||
            (chat.lastMessage?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    setState(() {});
  }

  void _showNewChatDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();

                if (name.isNotEmpty && email.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  await _createNewChat(name, email);
                }
              },
              child: const Text('Start Chat'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewChat(String name, String email) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // For now, we'll create a mock user ID based on email
        // In a real app, you'd look up the user by email
        final otherUserId = email.hashCode.toString();

        final chatId = await chatProvider.createChat(
          name: name,
          participantIds: [currentUser.uid, otherUserId],
          description: 'Chat with $name',
          isGroup: false,
        );

        if (chatId != null && mounted) {
          // Navigate to chat detail
          final chatUser = ChatUser(
            uid: otherUserId,
            email: email,
            displayName: name,
            isOnline: false,
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatDetailScreen(peer: chatUser)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create chat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterChats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Initialize filtered chats if not already done
        if (_filteredChats.isEmpty && chatProvider.chats.isNotEmpty) {
          _filteredChats = chatProvider.chats;
        } else if (_searchController.text.isEmpty) {
          _filteredChats = chatProvider.chats;
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1A2332),
                        const Color(0xFF0D1421),
                        const Color(0xFF0A0F1C),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Professional Purple Box Header
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientStart.withOpacity(),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Back Arrow
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Chat Icon
                        const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        // Title
                        const Expanded(
                          child: Text(
                            'Community Chat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Theme Toggle
                        GestureDetector(
                          onTap: widget.onThemeToggle,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart.withOpacity(),
                            AppColors.gradientEnd.withOpacity(),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gradientStart.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientStart.withOpacity(0.12),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: StatefulBuilder(
                        builder: (context, setSearchState) {
                          return TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              _filterChats();
                              setSearchState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search chats...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.gradientStart,
                                size: 24,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        _clearSearch();
                                        setSearchState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Chat List
                  Expanded(
                    child:
                        _filteredChats.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: isDark ? Colors.white60 : Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No chats found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching with a different name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredChats.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: isDark ? Colors.white60 : Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No chats yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start a conversation to see your chats here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withOpacity()
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredChats.length,
                            itemBuilder: (context, index) {
                              final chat = _filteredChats[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: RealChatTile(
                                  chat: chat,
                                  gradientIndex: index,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientStart.withOpacity(),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _showNewChatDialog(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add_comment_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Demo user model for chat
class ChatUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isOnline;

  ChatUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isOnline = false,
  });
}
