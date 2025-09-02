import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/common/message_bubble.dart';
import '../../models/chat_ui_models.dart';
import '../../../data/models/chat_model.dart';
import 'chat_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser peer;

  const ChatDetailScreen({super.key, required this.peer});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatId;
  late ChatProvider _chatProvider;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  void _initializeChat() async {
    if (_currentUser != null) {
      try {
        _chatId = await _chatProvider.createChat(
          name: widget.peer.displayName ?? widget.peer.email,
          participantIds: [_currentUser!.uid, widget.peer.uid],
          description: 'Private chat with ',
          isGroup: false,
        );

        if (_chatId != null) {
          await _chatProvider.selectChat(_chatId!);
        }
      } catch (e) {
        debugPrint('Error initializing Firebase chat: ');
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && _currentUser != null) {
      _chatProvider.sendMessage(
        _messageController.text.trim(),
        _currentUser!.uid,
        _currentUser!.displayName ?? _currentUser!.email ?? 'Anonymous',
      );

      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.messages;
        final isLoading = chatProvider.isLoading;
        final errorMessage = chatProvider.errorMessage;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0D1421)
              : const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // Professional Purple App Bar
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Back Arrow
                        GestureDetector(
                          onTap: () {
                            chatProvider.clearCurrentChat();
                            Navigator.pop(context);
                          },
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
                        // User Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            backgroundImage: widget.peer.photoUrl != null
                                ? NetworkImage(widget.peer.photoUrl!)
                                : null,
                            child: widget.peer.photoUrl == null
                                ? Text(
                                    (widget.peer.displayName ??
                                            widget.peer.email)
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.gradientStart,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.peer.displayName ?? widget.peer.email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.peer.isOnline
                                    ? 'Online'
                                    : 'Last seen recently',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Theme Toggle
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please use main screen theme toggle',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppColors.gradientStart,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
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
                ),
              ),
              // Messages List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [const Color(0xFF1A2332), const Color(0xFF0D1421)]
                          : [const Color(0xFFF8FAFC), const Color(0xFFE5DDD5)],
                    ),
                  ),
                  child: Column(
                    children: [
                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => chatProvider.clearError(),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                      Expanded(
                        child: isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.gradientStart,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading messages...',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.gradientStart
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 60,
                                        color: AppColors.gradientStart,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Start your conversation',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Send your first message to ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isMe =
                                      message.senderId == _currentUser?.uid;

                                  final chatMessage = ChatMessage(
                                    id: message.id,
                                    senderId: message.senderId,
                                    receiverId: '',
                                    text: message.content,
                                    timestamp: message.timestamp,
                                    seen: message.status == MessageStatus.read,
                                  );

                                  return MessageBubble(
                                    message: chatMessage,
                                    isMe: isMe,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Input Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2332) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A3441)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gradientStart.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
