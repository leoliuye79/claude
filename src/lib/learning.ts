import { Agent, Correction, LearningStats, Message, ReviewCard, TaskItem } from '../types';

const correctionRules = [
  {
    matcher: /i very like/gi,
    improved: 'I really like',
    reason: '`very like` 不自然，通常改成 `really like`。',
  },
  {
    matcher: /\bgoed\b/gi,
    improved: 'went',
    reason: '`go` 的过去式是不规则变化，应该用 `went`。',
  },
  {
    matcher: /i am agree/gi,
    improved: 'I agree',
    reason: '`agree` 在这里是动词，不需要 `am`。',
  },
];

export function createTimestamp(index: number): string {
  const minute = `${index % 60}`.padStart(2, '0');
  return `09:${minute}`;
}

export function analyzeMessage(message: Message): Correction | null {
  for (const rule of correctionRules) {
    if (rule.matcher.test(message.text)) {
      return {
        id: `correction-${message.id}`,
        original: message.text,
        improved: message.text.replace(rule.matcher, rule.improved),
        reason: rule.reason,
        sourceMessageId: message.id,
      };
    }
  }

  return null;
}

export function buildReviewCard(correction: Correction): ReviewCard {
  return {
    id: `review-${correction.id}`,
    title: '今天最值得复习的一句',
    wrong: correction.original,
    correct: correction.improved,
    note: correction.reason,
    status: 'new',
  };
}

export function createAgentReply(agent: Agent, userText: string, correction?: Correction | null): string {
  if (agent.type === 'grammar' && correction) {
    return `更自然的说法是：${correction.improved}\n原因：${correction.reason}\n你也可以自己再造一个类似句子，我帮你看。`;
  }

  if (agent.type === 'coach') {
    return `你刚刚已经完成了一小步。接下来试试把“${userText.slice(0, 18) || '今天的表达'}”扩展成两句话，这样任务会推进得更快。`;
  }

  if (correction) {
    return '我明白你的意思了。先继续聊下去也没问题，等会儿我会顺手帮你把一句话说得更自然。';
  }

  return `不错，我们继续。你刚提到“${userText.slice(0, 18) || '这个话题'}”，能不能再多说一点你的感受？`;
}

export function updateTasks(
  tasks: TaskItem[],
  options: { chatted?: boolean; viewedCorrection?: boolean; reviewedCard?: boolean }
): TaskItem[] {
  return tasks.map((task) => {
    let nextProgress = task.progress;

    if (task.id === 'task-chat' && options.chatted && task.status === 'todo') {
      nextProgress += 1;
    }

    if (task.id === 'task-grammar' && options.viewedCorrection && task.status === 'todo') {
      nextProgress = Math.max(nextProgress, 1);
    }

    if (task.id === 'task-review' && options.reviewedCard && task.status === 'todo') {
      nextProgress += 1;
    }

    const cappedProgress = Math.min(nextProgress, task.target);
    return {
      ...task,
      progress: cappedProgress,
      status: cappedProgress >= task.target ? 'done' : 'todo',
    };
  });
}

export function summarizeStats(
  messages: Record<string, Message[]>,
  cards: ReviewCard[],
  tasks: TaskItem[]
): LearningStats {
  const totalMessages = Object.values(messages).reduce((count, thread) => count + thread.length, 0);
  const correctionsSaved = cards.length;
  const reviewCardsMastered = cards.filter((card) => card.status === 'mastered').length;
  const streakDays = tasks.some((task) => task.status === 'done') ? 4 : 3;

  return {
    streakDays,
    totalMessages,
    correctionsSaved,
    reviewCardsMastered,
  };
}
