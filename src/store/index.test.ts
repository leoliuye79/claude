import { describe, it, expect, beforeEach } from 'vitest';
import { useStore } from './index';

beforeEach(() => {
  // Reset store to initial state
  useStore.setState({
    agents: useStore.getState().agents,
    conversations: [],
    messages: [],
    aiConfig: { provider: 'claude', apiKey: '', model: 'claude-sonnet-4-20250514' },
    onboardingDone: false,
    darkMode: false,
  });
});

describe('Store', () => {
  describe('onboarding', () => {
    it('should start with onboarding not done', () => {
      expect(useStore.getState().onboardingDone).toBe(false);
    });

    it('should complete onboarding', () => {
      useStore.getState().completeOnboarding();
      expect(useStore.getState().onboardingDone).toBe(true);
    });
  });

  describe('dark mode', () => {
    it('should toggle dark mode', () => {
      expect(useStore.getState().darkMode).toBe(false);
      useStore.getState().toggleDarkMode();
      expect(useStore.getState().darkMode).toBe(true);
      useStore.getState().toggleDarkMode();
      expect(useStore.getState().darkMode).toBe(false);
    });
  });

  describe('AI config', () => {
    it('should update AI config partially', () => {
      useStore.getState().setAIConfig({ apiKey: 'test-key' });
      const config = useStore.getState().aiConfig;
      expect(config.apiKey).toBe('test-key');
      expect(config.provider).toBe('claude');
    });

    it('should update provider and model', () => {
      useStore.getState().setAIConfig({ provider: 'openai', model: 'gpt-4o' });
      const config = useStore.getState().aiConfig;
      expect(config.provider).toBe('openai');
      expect(config.model).toBe('gpt-4o');
    });
  });

  describe('agents', () => {
    it('should have 6 default agents', () => {
      expect(useStore.getState().agents).toHaveLength(6);
    });

    it('should add custom agent', () => {
      const agent = {
        id: 'custom_test',
        name: 'Test Agent',
        nameZh: '测试',
        avatarUrl: '',
        role: 'friend' as const,
        style: 'casual' as const,
        correctionMode: 'immediate' as const,
        personality: 'Test personality',
        greeting: 'Hello!',
        targetLevel: 'beginner',
        topics: ['test'],
        isCustom: true,
        isActive: true,
        createdAt: new Date().toISOString(),
      };
      useStore.getState().addCustomAgent(agent);
      expect(useStore.getState().agents).toHaveLength(7);
      expect(useStore.getState().agents[6].id).toBe('custom_test');
    });
  });

  describe('conversations', () => {
    it('should create a conversation with greeting', () => {
      const agentId = useStore.getState().agents[0].id;
      const convId = useStore.getState().createConversation(agentId);

      expect(convId).toBeTruthy();
      expect(useStore.getState().conversations).toHaveLength(1);
      expect(useStore.getState().conversations[0].agentId).toBe(agentId);

      // Should have a greeting message
      const msgs = useStore.getState().messages.filter((m) => m.conversationId === convId);
      expect(msgs).toHaveLength(1);
      expect(msgs[0].sender).toBe('agent');
      expect(msgs[0].content).toBeTruthy();
    });

    it('should delete a conversation and its messages', () => {
      const agentId = useStore.getState().agents[0].id;
      const convId = useStore.getState().createConversation(agentId);

      expect(useStore.getState().conversations).toHaveLength(1);
      expect(useStore.getState().messages).toHaveLength(1);

      useStore.getState().deleteConversation(convId);

      expect(useStore.getState().conversations).toHaveLength(0);
      expect(useStore.getState().messages).toHaveLength(0);
    });

    it('should pin/unpin a conversation', () => {
      const agentId = useStore.getState().agents[0].id;
      const convId = useStore.getState().createConversation(agentId);

      expect(useStore.getState().conversations[0].isPinned).toBe(false);

      useStore.getState().pinConversation(convId);
      expect(useStore.getState().conversations[0].isPinned).toBe(true);

      useStore.getState().pinConversation(convId);
      expect(useStore.getState().conversations[0].isPinned).toBe(false);
    });

    it('should get conversation messages', () => {
      const agentId = useStore.getState().agents[0].id;
      const convId = useStore.getState().createConversation(agentId);

      const msgs = useStore.getState().getConversationMessages(convId);
      expect(msgs).toHaveLength(1);
    });
  });

  describe('sendMessage', () => {
    it('should add user message and prompt for API key when not configured', async () => {
      const agentId = useStore.getState().agents[0].id;
      const convId = useStore.getState().createConversation(agentId);

      await useStore.getState().sendMessage(convId, 'Hello!');

      const msgs = useStore.getState().messages.filter((m) => m.conversationId === convId);
      // greeting + user message + "set API key" message
      expect(msgs).toHaveLength(3);
      expect(msgs[1].sender).toBe('user');
      expect(msgs[1].content).toBe('Hello!');
      expect(msgs[2].sender).toBe('agent');
      expect(msgs[2].content).toContain('API Key');
    });

    it('should not send to non-existent conversation', async () => {
      const msgCountBefore = useStore.getState().messages.length;
      await useStore.getState().sendMessage('nonexistent', 'Hello!');
      expect(useStore.getState().messages.length).toBe(msgCountBefore);
    });
  });
});
