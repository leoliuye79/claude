import { describe, it, expect } from 'vitest';
import { buildSystemPrompt } from './systemPrompts';
import type { Agent } from '@/types';

const mockAgent: Agent = {
  id: 'test',
  name: 'Emma',
  nameZh: '艾玛',
  avatarUrl: '',
  role: 'teacher',
  style: 'encouraging',
  correctionMode: 'immediate',
  personality: 'Warm and patient.',
  greeting: 'Hi!',
  targetLevel: 'beginner',
  topics: ['daily life', 'food'],
  isCustom: false,
  isActive: true,
  createdAt: new Date().toISOString(),
};

describe('buildSystemPrompt', () => {
  it('should include agent name', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('Emma');
  });

  it('should include role and personality', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('teacher');
    expect(prompt).toContain('Warm and patient.');
  });

  it('should include teaching style instruction', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('warm and supportive');
  });

  it('should include correction mode instruction', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('immediately inline');
  });

  it('should include topics', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('daily life');
    expect(prompt).toContain('food');
  });

  it('should include correction JSON format', () => {
    const prompt = buildSystemPrompt(mockAgent);
    expect(prompt).toContain('```correction');
    expect(prompt).toContain('explanation_zh');
  });

  it('should not include topics section if no topics', () => {
    const agentNoTopics = { ...mockAgent, topics: [] };
    const prompt = buildSystemPrompt(agentNoTopics);
    expect(prompt).not.toContain('Preferred conversation topics');
  });
});
