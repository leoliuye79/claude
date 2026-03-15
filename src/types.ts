export type TabKey = 'chat' | 'tasks' | 'review' | 'profile';

export type AgentType = 'chat' | 'grammar' | 'coach';

export type Agent = {
  id: string;
  name: string;
  role: string;
  summary: string;
  accentColor: string;
  type: AgentType;
  greeting: string;
};

export type Message = {
  id: string;
  role: 'user' | 'agent';
  text: string;
  timestamp: string;
};

export type Correction = {
  id: string;
  original: string;
  improved: string;
  reason: string;
  sourceMessageId: string;
};

export type ReviewCard = {
  id: string;
  title: string;
  wrong: string;
  correct: string;
  note: string;
  status: 'new' | 'mastered';
};

export type TaskItem = {
  id: string;
  title: string;
  detail: string;
  progress: number;
  target: number;
  status: 'todo' | 'done';
};

export type LearningStats = {
  streakDays: number;
  totalMessages: number;
  correctionsSaved: number;
  reviewCardsMastered: number;
};
