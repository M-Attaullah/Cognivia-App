import 'package:flutter/foundation.dart';
import '../../data/models/chat_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;

  List<MessageModel> _messages = [];
  List<ChatModel> _chats = [];
  ChatModel? _currentChat;
  bool _isLoading = false;
  String? _errorMessage;

  ChatProvider({ChatService? chatService})
    : _chatService = chatService ?? ChatService();

  // Getters
  List<MessageModel> get messages => _messages;
  List<ChatModel> get chats => _chats;
  ChatModel? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load chats for current user
  Future<void> loadUserChats(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _chatService.getUserChats(userId).listen((chats) {
        _chats = chats;
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load chats: $e');
      _setLoading(false);
    }
  }

  // Select a chat and load its messages
  Future<void> selectChat(String chatId) async {
    try {
      _setLoading(true);
      _clearError();

      // Get chat details
      final chat = await _chatService.getChat(chatId);
      if (chat != null) {
        _currentChat = chat;

        // Listen to messages
        _chatService.getChatMessages(chatId).listen((messages) {
          _messages = messages;
          notifyListeners();
        });
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to select chat: $e');
      _setLoading(false);
    }
  }

  // Send a message
  Future<void> sendMessage(
    String messageText,
    String senderId,
    String senderName,
  ) async {
    if (_currentChat == null || messageText.trim().isEmpty) return;

    try {
      _clearError();

      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: _currentChat!.id,
        senderId: senderId,
        senderName: senderName,
        content: messageText.trim(),
        timestamp: DateTime.now(),
        type: MessageType.text,
        status: MessageStatus.sending,
      );

      await _chatService.sendMessage(message);
    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  // Create a new chat
  Future<String?> createChat({
    required String name,
    required List<String> participantIds,
    String description = '',
    bool isGroup = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final chat = ChatModel(
        id: '', // Will be set by the service
        name: name,
        description: description,
        participantIds: participantIds,
        createdAt: DateTime.now(),
        isGroup: isGroup,
      );

      final chatId = await _chatService.createChat(chat);
      _setLoading(false);
      return chatId;
    } catch (e) {
      _setError('Failed to create chat: $e');
      _setLoading(false);
      return null;
    }
  }

  // Leave current chat
  Future<void> leaveCurrentChat(String userId) async {
    if (_currentChat == null) return;

    try {
      _setLoading(true);
      _clearError();

      await _chatService.leaveChat(_currentChat!.id, userId);

      _currentChat = null;
      _messages.clear();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to leave chat: $e');
      _setLoading(false);
    }
  }

  // Clear current chat
  void clearCurrentChat() {
    _currentChat = null;
    _messages.clear();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Clear all data (for logout)
  void clearAllData() {
    _messages.clear();
    _chats.clear();
    _currentChat = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
