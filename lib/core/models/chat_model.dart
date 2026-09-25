class MessageModel {
  final String id;
  final String conversationId;
  final String senderType; // 'admin' or 'user'
  final String senderId;
  final String senderName;
  final String messageText;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderType: json['senderType'] ?? 'user',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? (json['senderType'] == 'admin' ? 'Admin Store' : 'Pelanggan'),
      messageText: json['messageText'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ConversationModel {
  final String id;
  final String userName;
  final String userSub;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String avatarUrl;

  ConversationModel({
    required this.id,
    required this.userName,
    required this.userSub,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.avatarUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      userName: json['user']?['name'] ?? json['userName'] ?? 'Pelanggan',
      userSub: json['userSub'] ?? 'Instansi / Pembeli',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      avatarUrl: json['user']?['profilePhoto'] ?? json['avatarUrl'] ?? '',
    );
  }
}
