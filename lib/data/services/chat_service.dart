import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get all chats for current user
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _database.child('userChats').child(userId).onValue.asyncMap((
      event,
    ) async {
      if (event.snapshot.value == null) return <ChatModel>[];

      final chatIds = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<ChatModel> chats = [];

      // Fetch each chat details
      for (String chatId in chatIds.keys) {
        final chat = await getChat(chatId);
        if (chat != null) {
          chats.add(chat);
        }
      }

      return chats;
    });
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _database
        .child('chatMessages')
        .child(chatId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return <MessageModel>[];

          final messagesData = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );
          final List<MessageModel> messages = [];

          messagesData.forEach((key, value) {
            final messageMap = Map<String, dynamic>.from(value as Map);
            messages.add(MessageModel.fromJson(messageMap));
          });

          // Sort by timestamp
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    try {
      final messageRef = _database
          .child('chatMessages')
          .child(message.chatId)
          .push();

      await messageRef.set(message.toJson());

      // Update last message in chat
      await _database.child('chats').child(message.chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Create a new chat
  Future<String> createChat(ChatModel chat) async {
    try {
      final chatRef = _database.child('chats').push();
      final chatId = chatRef.key!;

      final chatWithId = ChatModel(
        id: chatId,
        name: chat.name,
        description: chat.description,
        participantIds: chat.participantIds,
        createdBy: currentUserId,
        createdAt: DateTime.now(),
        isGroup: chat.isGroup,
      );

      await chatRef.set(chatWithId.toJson());

      // Add chat to each participant's chat list
      for (String participantId in chat.participantIds) {
        await _database
            .child('userChats')
            .child(participantId)
            .child(chatId)
            .set(true);
      }

      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Get chat details
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final snapshot = await _database.child('chats').child(chatId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return ChatModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Get chat participants first
      final chat = await getChat(chatId);
      if (chat != null) {
        // Remove from each participant's chat list
        for (String participantId in chat.participantIds) {
          await _database
              .child('userChats')
              .child(participantId)
              .child(chatId)
              .remove();
        }

        // Delete chat messages
        await _database.child('chatMessages').child(chatId).remove();

        // Delete chat
        await _database.child('chats').child(chatId).remove();
      }
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // Leave a chat
  Future<void> leaveChat(String chatId, String userId) async {
    try {
      // Remove user from chat participants
      await _database
          .child('chats')
          .child(chatId)
          .child('participantIds')
          .child(userId)
          .remove();

      // Remove chat from user's chat list
      await _database.child('userChats').child(userId).child(chatId).remove();
    } catch (e) {
      throw Exception('Failed to leave chat: $e');
    }
  }
}
