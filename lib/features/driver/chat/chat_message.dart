class ChatMessage {
  final int id;
  final int? rideId;
  final int senderId;
  final String senderRole;
  final String body;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.rideId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  bool isMine(int myUserId) => senderId == myUserId;

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as int,
        rideId: j['rideId'] as int?,
        senderId: j['senderId'] as int,
        senderRole: j['senderRole']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
