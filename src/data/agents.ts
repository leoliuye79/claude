import { Agent, Message, TaskItem } from '../types';

export const agents: Agent[] = [
  {
    id: 'mia',
    name: 'Mia',
    role: '陪聊好友',
    summary: '陪你轻松聊天，帮你慢慢敢开口。',
    accentColor: '#FF8C69',
    type: 'chat',
    greeting: '今天想聊点什么？你可以先用简单句开始，我会陪你慢慢说自然。',
  },
  {
    id: 'ethan',
    name: 'Ethan',
    role: '语法老师',
    summary: '帮你看懂哪里不自然，以及怎么说更地道。',
    accentColor: '#2C6E63',
    type: 'grammar',
    greeting: '把你想确认的句子发给我，我会用最短的方式讲清楚。',
  },
  {
    id: 'nova',
    name: 'Nova',
    role: '任务教练',
    summary: '给你今天的练习任务，陪你稳定坚持。',
    accentColor: '#316BFF',
    type: 'coach',
    greeting: '今天的目标很轻量，我们先完成一小步就好。',
  },
];

export const initialMessages: Record<string, Message[]> = {
  mia: [
    {
      id: 'mia-1',
      role: 'agent',
      text: '嗨，我是 Mia。今天先随便聊聊吧，比如你早餐吃了什么？',
      timestamp: '09:00',
    },
  ],
  ethan: [
    {
      id: 'ethan-1',
      role: 'agent',
      text: '我是 Ethan。把一句你觉得不顺的表达发给我，我来帮你修。',
      timestamp: '09:00',
    },
  ],
  nova: [
    {
      id: 'nova-1',
      role: 'agent',
      text: '今天有 3 个轻量任务。先和 Mia 完成 5 轮对话，我们就开个好头。',
      timestamp: '09:00',
    },
  ],
};

export const initialTasks: TaskItem[] = [
  {
    id: 'task-chat',
    title: '和 Mia 完成 5 轮对话',
    detail: '大胆表达，先说出来比完全正确更重要。',
    progress: 0,
    target: 5,
    status: 'todo',
  },
  {
    id: 'task-grammar',
    title: '查看 1 次纠错解释',
    detail: '把今天最重要的一个错误真正看懂。',
    progress: 0,
    target: 1,
    status: 'todo',
  },
  {
    id: 'task-review',
    title: '完成 2 张复习卡片',
    detail: '复习来自真实聊天内容，效率更高。',
    progress: 0,
    target: 2,
    status: 'todo',
  },
];
