enum MessageType { text, image, file, system }

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatModel {
  final String id;
  final String name;
  final String description;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? createdBy;
  final DateTime createdAt;
  final bool isGroup;
  final String? groupImage;

  ChatModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.createdBy,
    required this.createdAt,
    this.isGroup = false,
    this.groupImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isGroup': isGroup,
      'groupImage': groupImage,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      participantIds: List<String>.from(json['participantIds'] as List),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'] as int)
          : null,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isGroup: json['isGroup'] as bool? ?? false,
      groupImage: json['groupImage'] as String?,
    );
  }

  ChatModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? createdBy,
    DateTime? createdAt,
    bool? isGroup,
    String? groupImage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isGroup: isGroup ?? this.isGroup,
      groupImage: groupImage ?? this.groupImage,
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? replyToId;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, dynamic>? metadata; // For file info, image dimensions, etc.

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.replyToId,
    this.isEdited = false,
    this.editedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'replyToId': replyToId,
      'isEdited': isEdited,
      'editedAt': editedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      replyToId: json['replyToId'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? replyToId,
    bool? isEdited,
    DateTime? editedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      replyToId: replyToId ?? this.replyToId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
