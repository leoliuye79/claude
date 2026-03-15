import { agents, initialTasks } from '../src/data/agents';
import { analyzeMessage, buildReviewCard, createAgentReply, summarizeStats, updateTasks } from '../src/lib/learning';
import { Message } from '../src/types';

describe('learning helpers', () => {
  it('detects a correction and builds a review card', () => {
    const message: Message = {
      id: 'm1',
      role: 'user',
      text: 'I very like coffee.',
      timestamp: '09:01',
    };

    const correction = analyzeMessage(message);
    expect(correction).not.toBeNull();
    expect(correction?.improved).toBe('I really like coffee.');

    const card = buildReviewCard(correction!);
    expect(card.correct).toBe('I really like coffee.');
    expect(card.status).toBe('new');
  });

  it('updates tasks and summarizes stats', () => {
    const progressed = updateTasks(initialTasks, { chatted: true, viewedCorrection: true, reviewedCard: true });
    expect(progressed.find((task) => task.id === 'task-chat')?.progress).toBe(1);
    expect(progressed.find((task) => task.id === 'task-grammar')?.status).toBe('done');

    const stats = summarizeStats(
      {
        mia: [{ id: '1', role: 'agent', text: 'Hi', timestamp: '09:00' }],
        ethan: [],
        nova: [],
      },
      [
        {
          id: 'c1',
          title: 't',
          wrong: 'a',
          correct: 'b',
          note: 'n',
          status: 'mastered',
        },
      ],
      progressed
    );

    expect(stats.correctionsSaved).toBe(1);
    expect(stats.reviewCardsMastered).toBe(1);
    expect(stats.streakDays).toBe(4);
  });

  it('generates replies per agent role', () => {
    const reply = createAgentReply(agents[0], 'I like music');
    const grammarReply = createAgentReply(
      agents[1],
      'I very like coffee',
      {
        id: 'c1',
        original: 'I very like coffee',
        improved: 'I really like coffee',
        reason: 'Use really like.',
        sourceMessageId: 'm1',
      }
    );

    expect(reply).toContain('不错');
    expect(grammarReply).toContain('更自然的说法');
  });
});
