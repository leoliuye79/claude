import type { Agent } from '@/types';

const TEACHING_STYLE_INSTRUCTIONS: Record<string, string> = {
  strict: 'Be precise and thorough. Point out every error. Maintain high standards.',
  encouraging: 'Be warm and supportive. Celebrate progress. Gently correct errors.',
  casual: 'Be relaxed and friendly. Use natural language. Correct only major errors.',
  socratic: 'Ask guiding questions. Help the student discover answers on their own.',
};

const CORRECTION_MODE_INSTRUCTIONS: Record<string, string> = {
  immediate: 'Correct grammar errors immediately inline as they occur in the conversation.',
  endOfTurn: 'Respond naturally first, then summarize any corrections at the end of your turn.',
  onRequest: 'Only correct grammar when the student explicitly asks for correction.',
};

export function buildSystemPrompt(agent: Agent): string {
  const parts: string[] = [
    `You are ${agent.name}, a language learning partner.`,
    `Your role: ${agent.role}. Your personality: ${agent.personality}`,
    '',
    `The student's level is: ${agent.targetLevel}.`,
    `Teaching style: ${TEACHING_STYLE_INSTRUCTIONS[agent.style]}`,
    `Correction mode: ${CORRECTION_MODE_INSTRUCTIONS[agent.correctionMode]}`,
    '',
    'IMPORTANT RULES:',
    '1. Always respond naturally as your character.',
    '2. Keep responses concise (2-4 sentences for casual chat).',
    '3. Mix English with brief Chinese explanations when helpful.',
    '4. Adapt difficulty to the student\'s level.',
  ];

  if (agent.topics.length > 0) {
    parts.push(`5. Preferred conversation topics: ${agent.topics.join(', ')}.`);
  }

  parts.push(
    '',
    'When providing corrections, include a JSON block in this format:',
    '```correction',
    JSON.stringify({
      original: '<what the student said>',
      corrected: '<corrected version>',
      details: [
        {
          incorrect: '<error>',
          correct: '<fix>',
          explanation_zh: '<中文解释>',
          explanation_en: '<English explanation>',
          example: '<example sentence>',
        },
      ],
    }, null, 2),
    '```',
  );

  return parts.join('\n');
}
