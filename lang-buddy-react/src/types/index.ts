export type AgentRole = 'teacher' | 'friend' | 'colleague' | 'tutor' | 'travelBuddy' | 'interviewCoach';
export type TeachingStyle = 'strict' | 'encouraging' | 'casual' | 'socratic';
export type CorrectionMode = 'immediate' | 'endOfTurn' | 'onRequest';
export type MessageType = 'text' | 'voice' | 'correction' | 'systemNotice';
export type MessageStatus = 'sending' | 'sent' | 'failed';
export type MessageSender = 'user' | 'agent';
export type AIProvider = 'claude' | 'openai' | 'custom';

export const ROLE_LABELS: Record<AgentRole, string> = {
  teacher: '老师',
  friend: '朋友',
  colleague: '同事',
  tutor: '辅导员',
  travelBuddy: '旅行伙伴',
  interviewCoach: '面试教练',
};

export interface Agent {
  id: string;
  name: string;
  nameZh: string;
  avatarUrl: string;
  role: AgentRole;
  style: TeachingStyle;
  correctionMode: CorrectionMode;
  personality: string;
  greeting: string;
  targetLevel: string;
  topics: string[];
  isCustom: boolean;
  isActive: boolean;
  createdAt: string;
}

export interface CorrectionDetail {
  incorrect: string;
  correct: string;
  explanationZh: string;
  explanationEn: string;
  example?: string;
}

export interface Correction {
  originalText: string;
  correctedText: string;
  details: CorrectionDetail[];
}

export interface Message {
  id: string;
  conversationId: string;
  sender: MessageSender;
  type: MessageType;
  content: string;
  audioPath?: string;
  audioDurationMs?: number;
  correction?: Correction;
  status: MessageStatus;
  createdAt: string;
}

export interface Conversation {
  id: string;
  agentId: string;
  lastMessagePreview?: string;
  lastMessageAt?: string;
  unreadCount: number;
  isPinned: boolean;
  createdAt: string;
}

export interface AIModelConfig {
  provider: AIProvider;
  apiKey: string;
  model: string;
  baseUrl?: string;
}
