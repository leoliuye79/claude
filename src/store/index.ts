import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { v4 as uuidv4 } from 'uuid';
import type { Agent, AIModelConfig, Conversation, Message } from '@/types';
import { defaultAgents } from '@/config/defaultAgents';
import { buildSystemPrompt } from '@/config/systemPrompts';
import { sendMessage as sendAIMessage } from '@/services/aiClient';

interface AppState {
  // Data
  agents: Agent[];
  conversations: Conversation[];
  messages: Message[];
  aiConfig: AIModelConfig;
  onboardingDone: boolean;
  darkMode: boolean;

  // Actions
  completeOnboarding: () => void;
  toggleDarkMode: () => void;
  setAIConfig: (config: Partial<AIModelConfig>) => void;

  // Agent actions
  addCustomAgent: (agent: Agent) => void;

  // Conversation actions
  createConversation: (agentId: string) => string;
  deleteConversation: (id: string) => void;
  pinConversation: (id: string) => void;

  // Message actions
  getConversationMessages: (conversationId: string) => Message[];
  sendMessage: (conversationId: string, content: string) => Promise<void>;
}

export const useStore = create<AppState>()(
  persist(
    (set, get) => ({
      agents: defaultAgents,
      conversations: [],
      messages: [],
      aiConfig: {
        provider: 'claude',
        apiKey: '',
        model: 'claude-sonnet-4-20250514',
      },
      onboardingDone: false,
      darkMode: false,

      completeOnboarding: () => set({ onboardingDone: true }),

      toggleDarkMode: () => set((s) => ({ darkMode: !s.darkMode })),

      setAIConfig: (config) =>
        set((s) => ({ aiConfig: { ...s.aiConfig, ...config } })),

      addCustomAgent: (agent) =>
        set((s) => ({ agents: [...s.agents, agent] })),

      createConversation: (agentId: string) => {
        const id = uuidv4();
        const agent = get().agents.find((a) => a.id === agentId);
        const conv: Conversation = {
          id,
          agentId,
          lastMessagePreview: agent?.greeting,
          lastMessageAt: new Date().toISOString(),
          unreadCount: 0,
          isPinned: false,
          createdAt: new Date().toISOString(),
        };
        // Add greeting message
        const greetingMsg: Message = {
          id: uuidv4(),
          conversationId: id,
          sender: 'agent',
          type: 'text',
          content: agent?.greeting ?? '',
          status: 'sent',
          createdAt: new Date().toISOString(),
        };
        set((s) => ({
          conversations: [conv, ...s.conversations],
          messages: [...s.messages, greetingMsg],
        }));
        return id;
      },

      deleteConversation: (id) =>
        set((s) => ({
          conversations: s.conversations.filter((c) => c.id !== id),
          messages: s.messages.filter((m) => m.conversationId !== id),
        })),

      pinConversation: (id) =>
        set((s) => ({
          conversations: s.conversations.map((c) =>
            c.id === id ? { ...c, isPinned: !c.isPinned } : c
          ),
        })),

      getConversationMessages: (conversationId) => {
        return get().messages.filter((m) => m.conversationId === conversationId);
      },

      sendMessage: async (conversationId, content) => {
        const state = get();
        const conv = state.conversations.find((c) => c.id === conversationId);
        if (!conv) return;

        const agent = state.agents.find((a) => a.id === conv.agentId);
        if (!agent) return;

        // Add user message
        const userMsg: Message = {
          id: uuidv4(),
          conversationId,
          sender: 'user',
          type: 'text',
          content,
          status: 'sent',
          createdAt: new Date().toISOString(),
        };

        set((s) => ({
          messages: [...s.messages, userMsg],
          conversations: s.conversations.map((c) =>
            c.id === conversationId
              ? { ...c, lastMessagePreview: content, lastMessageAt: new Date().toISOString() }
              : c
          ),
        }));

        // Send to AI
        if (!state.aiConfig.apiKey) {
          const demoMsg: Message = {
            id: uuidv4(),
            conversationId,
            sender: 'agent',
            type: 'text',
            content: '请先在设置中配置 API Key 才能与我对话哦！Go to Settings → AI Model to set your API key.',
            status: 'sent',
            createdAt: new Date().toISOString(),
          };
          set((s) => ({
            messages: [...s.messages, demoMsg],
            conversations: s.conversations.map((c) =>
              c.id === conversationId
                ? { ...c, lastMessagePreview: demoMsg.content, lastMessageAt: new Date().toISOString() }
                : c
            ),
          }));
          return;
        }

        try {
          const history = get()
            .messages.filter((m) => m.conversationId === conversationId && m.type === 'text')
            .slice(-20)
            .map((m) => ({
              role: m.sender === 'user' ? 'user' as const : 'assistant' as const,
              content: m.content,
            }));

          const systemPrompt = buildSystemPrompt(agent);
          const resp = await sendAIMessage(state.aiConfig, systemPrompt, history);

          const agentMsg: Message = {
            id: uuidv4(),
            conversationId,
            sender: 'agent',
            type: 'text',
            content: resp.content,
            correction: resp.correction,
            status: 'sent',
            createdAt: new Date().toISOString(),
          };

          set((s) => ({
            messages: [...s.messages, agentMsg],
            conversations: s.conversations.map((c) =>
              c.id === conversationId
                ? { ...c, lastMessagePreview: resp.content.slice(0, 50), lastMessageAt: new Date().toISOString() }
                : c
            ),
          }));
        } catch (err) {
          const errorMsg: Message = {
            id: uuidv4(),
            conversationId,
            sender: 'agent',
            type: 'systemNotice',
            content: `发送失败: ${err instanceof Error ? err.message : 'Unknown error'}`,
            status: 'failed',
            createdAt: new Date().toISOString(),
          };
          set((s) => ({ messages: [...s.messages, errorMsg] }));
        }
      },
    }),
    {
      name: 'lang-buddy-storage',
      version: 1,
      partialize: (state) => ({
        agents: state.agents,
        conversations: state.conversations,
        messages: state.messages,
        aiConfig: state.aiConfig,
        onboardingDone: state.onboardingDone,
        darkMode: state.darkMode,
      }),
      merge: (persisted, current) => {
        const persistedState = persisted as Partial<AppState> | undefined;
        if (!persistedState) return current;

        // Merge default agents: keep all persisted agents but add any new defaults
        const persistedAgents = persistedState.agents ?? [];
        const persistedIds = new Set(persistedAgents.map((a) => a.id));
        const newDefaults = defaultAgents.filter((a) => !persistedIds.has(a.id));
        const mergedAgents = [...persistedAgents, ...newDefaults];

        return {
          ...current,
          ...persistedState,
          agents: mergedAgents,
        };
      },
    }
  )
);
