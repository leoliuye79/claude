import type { AIModelConfig, Correction } from '@/types';

interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

interface AIResponse {
  content: string;
  correction?: Correction;
}

function parseCorrectionBlock(text: string): Correction | undefined {
  const match = text.match(/```correction\s*([\s\S]*?)```/);
  if (!match) return undefined;
  try {
    const parsed = JSON.parse(match[1]);
    return {
      originalText: parsed.original ?? '',
      correctedText: parsed.corrected ?? '',
      details: (parsed.details ?? []).map((d: Record<string, string>) => ({
        incorrect: d.incorrect ?? '',
        correct: d.correct ?? '',
        explanationZh: d.explanation_zh ?? '',
        explanationEn: d.explanation_en ?? '',
        example: d.example,
      })),
    };
  } catch {
    return undefined;
  }
}

function cleanContent(text: string): string {
  return text.replace(/```correction[\s\S]*?```/g, '').trim();
}

async function sendToClaude(
  config: AIModelConfig,
  systemPrompt: string,
  messages: ChatMessage[],
): Promise<AIResponse> {
  const resp = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': config.apiKey,
      'anthropic-version': '2023-06-01',
      'anthropic-dangerous-direct-browser-access': 'true',
    },
    body: JSON.stringify({
      model: config.model || 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: systemPrompt,
      messages: messages.map((m) => ({ role: m.role === 'system' ? 'user' : m.role, content: m.content })),
    }),
  });

  if (!resp.ok) {
    const err = await resp.text();
    throw new Error(`Claude API error: ${resp.status} ${err}`);
  }

  const data = await resp.json();
  const rawContent = data.content?.[0]?.text ?? '';
  const correction = parseCorrectionBlock(rawContent);
  return { content: cleanContent(rawContent), correction };
}

async function sendToOpenAI(
  config: AIModelConfig,
  systemPrompt: string,
  messages: ChatMessage[],
): Promise<AIResponse> {
  const baseUrl = config.baseUrl || 'https://api.openai.com/v1';
  const resp = await fetch(`${baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.apiKey}`,
    },
    body: JSON.stringify({
      model: config.model || 'gpt-4o',
      messages: [{ role: 'system', content: systemPrompt }, ...messages],
    }),
  });

  if (!resp.ok) {
    const err = await resp.text();
    throw new Error(`OpenAI API error: ${resp.status} ${err}`);
  }

  const data = await resp.json();
  const rawContent = data.choices?.[0]?.message?.content ?? '';
  const correction = parseCorrectionBlock(rawContent);
  return { content: cleanContent(rawContent), correction };
}

export async function sendMessage(
  config: AIModelConfig,
  systemPrompt: string,
  messages: ChatMessage[],
): Promise<AIResponse> {
  if (config.provider === 'claude') {
    return sendToClaude(config, systemPrompt, messages);
  }
  return sendToOpenAI(config, systemPrompt, messages);
}
