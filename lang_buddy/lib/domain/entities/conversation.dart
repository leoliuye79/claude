class Conversation {
  final String id;
  final String agentId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isPinned;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.agentId,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.createdAt,
  });

  Conversation copyWith({
    String? id,
    String? agentId,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
