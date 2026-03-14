import { describe, it, expect, vi, beforeEach } from 'vitest';
import { sendMessage } from './aiClient';
import type { AIModelConfig } from '@/types';

const mockFetch = vi.fn();
globalThis.fetch = mockFetch;

beforeEach(() => {
  mockFetch.mockReset();
});

describe('aiClient', () => {
  describe('sendMessage with Claude', () => {
    const config: AIModelConfig = {
      provider: 'claude',
      apiKey: 'test-key',
      model: 'claude-sonnet-4-20250514',
    };

    it('should send to Claude API and parse response', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          content: [{ text: 'Hello! How are you?' }],
        }),
      });

      const result = await sendMessage(config, 'You are a teacher', [
        { role: 'user', content: 'Hi!' },
      ]);

      expect(result.content).toBe('Hello! How are you?');
      expect(result.correction).toBeUndefined();
      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.anthropic.com/v1/messages',
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'x-api-key': 'test-key',
          }),
        }),
      );
    });

    it('should parse correction blocks', async () => {
      const textWithCorrection = `Great effort! Here's a small correction.

\`\`\`correction
{
  "original": "I go to school yesterday",
  "corrected": "I went to school yesterday",
  "details": [
    {
      "incorrect": "go",
      "correct": "went",
      "explanation_zh": "过去时应使用went",
      "explanation_en": "Use past tense 'went' for past actions",
      "example": "I went to the park last week."
    }
  ]
}
\`\`\``;

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          content: [{ text: textWithCorrection }],
        }),
      });

      const result = await sendMessage(config, 'You are a teacher', [
        { role: 'user', content: 'I go to school yesterday' },
      ]);

      expect(result.content).toBe("Great effort! Here's a small correction.");
      expect(result.correction).toBeDefined();
      expect(result.correction!.originalText).toBe('I go to school yesterday');
      expect(result.correction!.correctedText).toBe('I went to school yesterday');
      expect(result.correction!.details).toHaveLength(1);
      expect(result.correction!.details[0].incorrect).toBe('go');
      expect(result.correction!.details[0].correct).toBe('went');
    });

    it('should throw on API error', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        text: async () => 'Unauthorized',
      });

      await expect(
        sendMessage(config, 'prompt', [{ role: 'user', content: 'hi' }]),
      ).rejects.toThrow('Claude API error: 401');
    });
  });

  describe('sendMessage with OpenAI', () => {
    const config: AIModelConfig = {
      provider: 'openai',
      apiKey: 'sk-test',
      model: 'gpt-4o',
    };

    it('should send to OpenAI API', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          choices: [{ message: { content: 'Hello from OpenAI!' } }],
        }),
      });

      const result = await sendMessage(config, 'You are a teacher', [
        { role: 'user', content: 'Hi!' },
      ]);

      expect(result.content).toBe('Hello from OpenAI!');
      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.openai.com/v1/chat/completions',
        expect.objectContaining({ method: 'POST' }),
      );
    });

    it('should use custom base URL', async () => {
      const customConfig: AIModelConfig = {
        provider: 'custom',
        apiKey: 'sk-test',
        model: 'custom-model',
        baseUrl: 'https://custom.api.com/v1',
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          choices: [{ message: { content: 'Custom response' } }],
        }),
      });

      await sendMessage(customConfig, 'prompt', [{ role: 'user', content: 'hi' }]);

      expect(mockFetch).toHaveBeenCalledWith(
        'https://custom.api.com/v1/chat/completions',
        expect.anything(),
      );
    });
  });
});
