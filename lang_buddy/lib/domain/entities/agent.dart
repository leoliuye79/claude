enum AgentRole {
  teacher,
  friend,
  colleague,
  tutor,
  travelBuddy,
  interviewCoach;

  String get label => switch (this) {
        teacher => '老师',
        friend => '朋友',
        colleague => '同事',
        tutor => '辅导员',
        travelBuddy => '旅行伙伴',
        interviewCoach => '面试教练',
      };
}

enum TeachingStyle {
  strict,
  encouraging,
  casual,
  socratic;

  String get instruction => switch (this) {
        strict =>
          'Be precise and thorough. Point out every error. Maintain high standards.',
        encouraging =>
          'Be warm and supportive. Celebrate progress. Gently correct errors.',
        casual =>
          'Be relaxed and friendly. Use natural language. Correct only major errors.',
        socratic =>
          'Ask guiding questions. Help the student discover answers on their own.',
      };
}

enum CorrectionMode {
  immediate,
  endOfTurn,
  onRequest;

  String get instruction => switch (this) {
        immediate =>
          'Correct grammar errors immediately inline as they occur in the conversation.',
        endOfTurn =>
          'Respond naturally first, then summarize any corrections at the end of your turn.',
        onRequest =>
          'Only correct grammar when the student explicitly asks for correction.',
      };
}

class Agent {
  final String id;
  final String name;
  final String nameZh;
  final String avatarUrl;
  final AgentRole role;
  final TeachingStyle style;
  final CorrectionMode correctionMode;
  final String personality;
  final String greeting;
  final String targetLevel;
  final List<String> topics;
  final bool isCustom;
  final bool isActive;
  final DateTime createdAt;

  const Agent({
    required this.id,
    required this.name,
    required this.nameZh,
    required this.avatarUrl,
    required this.role,
    required this.style,
    required this.correctionMode,
    required this.personality,
    required this.greeting,
    required this.targetLevel,
    required this.topics,
    this.isCustom = false,
    this.isActive = true,
    required this.createdAt,
  });

  Agent copyWith({
    String? id,
    String? name,
    String? nameZh,
    String? avatarUrl,
    AgentRole? role,
    TeachingStyle? style,
    CorrectionMode? correctionMode,
    String? personality,
    String? greeting,
    String? targetLevel,
    List<String>? topics,
    bool? isCustom,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      nameZh: nameZh ?? this.nameZh,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      style: style ?? this.style,
      correctionMode: correctionMode ?? this.correctionMode,
      personality: personality ?? this.personality,
      greeting: greeting ?? this.greeting,
      targetLevel: targetLevel ?? this.targetLevel,
      topics: topics ?? this.topics,
      isCustom: isCustom ?? this.isCustom,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
