import { StatusBar } from 'expo-status-bar';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { agents, initialMessages, initialTasks } from './src/data/agents';
import { analyzeMessage, buildReviewCard, createAgentReply, createTimestamp, summarizeStats, updateTasks } from './src/lib/learning';
import { appStyles, palette } from './src/styles';
import { Correction, Message, ReviewCard, TabKey, TaskItem } from './src/types';

const languageOptions = ['英语', '日语', '韩语'];
const levelOptions = ['零基础', '初级', '中级', '高级'];
const goalOptions = ['日常交流', '旅行表达', '工作沟通', '面试准备'];

export default function App() {
  const [started, setStarted] = useState(false);
  const [language, setLanguage] = useState('英语');
  const [level, setLevel] = useState('初级');
  const [goal, setGoal] = useState('日常交流');
  const [activeTab, setActiveTab] = useState<TabKey>('chat');
  const [selectedAgentId, setSelectedAgentId] = useState('mia');
  const [messagesByAgent, setMessagesByAgent] = useState(initialMessages);
  const [draft, setDraft] = useState('');
  const [latestCorrection, setLatestCorrection] = useState<Correction | null>(null);
  const [reviewCards, setReviewCards] = useState<ReviewCard[]>([]);
  const [tasks, setTasks] = useState<TaskItem[]>(initialTasks);

  const selectedAgent = agents.find((agent) => agent.id === selectedAgentId) ?? agents[0];
  const selectedMessages = messagesByAgent[selectedAgentId];
  const stats = useMemo(() => summarizeStats(messagesByAgent, reviewCards, tasks), [messagesByAgent, reviewCards, tasks]);

  const sendMessage = () => {
    const trimmed = draft.trim();
    if (!trimmed) {
      return;
    }

    const baseMessages = messagesByAgent[selectedAgentId] ?? [];
    const userMessage: Message = {
      id: `${selectedAgentId}-${baseMessages.length + 1}`,
      role: 'user',
      text: trimmed,
      timestamp: createTimestamp(baseMessages.length + 1),
    };
    const correction = analyzeMessage(userMessage);
    const replyMessage: Message = {
      id: `${selectedAgentId}-${baseMessages.length + 2}`,
      role: 'agent',
      text: createAgentReply(selectedAgent, trimmed, correction),
      timestamp: createTimestamp(baseMessages.length + 2),
    };

    setMessagesByAgent((current) => ({
      ...current,
      [selectedAgentId]: [...baseMessages, userMessage, replyMessage],
    }));
    setLatestCorrection(correction);
    setTasks((current) => updateTasks(current, { chatted: selectedAgentId === 'mia' }));
    setDraft('');
  };

  const saveCorrectionToReview = () => {
    if (!latestCorrection) {
      return;
    }

    setReviewCards((current) => {
      if (current.some((card) => card.id === `review-${latestCorrection.id}`)) {
        return current;
      }

      return [buildReviewCard(latestCorrection), ...current];
    });
  };

  const openGrammarCoach = () => {
    if (!latestCorrection) {
      return;
    }

    setSelectedAgentId('ethan');
    setActiveTab('chat');
    setTasks((current) => updateTasks(current, { viewedCorrection: true }));
    setMessagesByAgent((current) => {
      const thread = current.ethan ?? [];
      const alreadyInjected = thread.some((message) => message.id === `ethan-${latestCorrection.id}`);
      if (alreadyInjected) {
        return current;
      }

      const grammarMessage: Message = {
        id: `ethan-${latestCorrection.id}`,
        role: 'agent',
        text: createAgentReply(agents[1], latestCorrection.original, latestCorrection),
        timestamp: createTimestamp(thread.length + 1),
      };

      return {
        ...current,
        ethan: [...thread, grammarMessage],
      };
    });
  };

  const masterReviewCard = (cardId: string) => {
    setReviewCards((current) =>
      current.map((card) =>
        card.id === cardId
          ? {
              ...card,
              status: 'mastered',
            }
          : card
      )
    );
    setTasks((current) => updateTasks(current, { reviewedCard: true }));
  };

  const resetDemo = () => {
    setStarted(false);
    setLanguage('英语');
    setLevel('初级');
    setGoal('日常交流');
    setActiveTab('chat');
    setSelectedAgentId('mia');
    setMessagesByAgent(initialMessages);
    setDraft('');
    setLatestCorrection(null);
    setReviewCards([]);
    setTasks(initialTasks);
  };

  const renderOptionGroup = (
    title: string,
    options: string[],
    current: string,
    onSelect: (value: string) => void
  ) => (
    <View style={appStyles.sectionCard}>
      <Text style={appStyles.agentName}>{title}</Text>
      <View style={appStyles.optionGrid}>
        {options.map((option) => {
          const active = current === option;
          return (
            <Pressable
              key={option}
              onPress={() => onSelect(option)}
              style={[appStyles.optionCard, active && appStyles.optionCardActive]}
            >
              <Text style={[appStyles.optionText, active && appStyles.optionTextActive]}>{option}</Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );

  const renderChatTab = () => (
    <>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 12 }}>
        {agents.map((agent) => {
          const selected = agent.id === selectedAgentId;
          return (
            <Pressable
              key={agent.id}
              onPress={() => setSelectedAgentId(agent.id)}
              style={[
                appStyles.agentPill,
                {
                  backgroundColor: selected ? agent.accentColor : palette.white,
                  borderColor: selected ? agent.accentColor : palette.line,
                },
              ]}
            >
              <Text style={appStyles.agentName}>{agent.name}</Text>
              <Text style={appStyles.agentRole}>{agent.role}</Text>
            </Pressable>
          );
        })}
      </ScrollView>

      <View style={appStyles.sectionCard}>
        <Text style={appStyles.agentName}>
          {selectedAgent.name} · {selectedAgent.role}
        </Text>
        <Text style={[appStyles.smallText, { marginTop: 6, marginBottom: 10 }]}>
          {selectedAgent.summary} 当前模式：{language} · {level} · {goal}
        </Text>
        {selectedMessages.map((message) => (
          <View
            key={message.id}
            style={[
              appStyles.messageBubble,
              message.role === 'user' ? appStyles.userBubble : appStyles.agentBubble,
            ]}
          >
            <Text style={appStyles.messageText}>{message.text}</Text>
          </View>
        ))}

        {latestCorrection && selectedAgentId !== 'ethan' ? (
          <View style={appStyles.correctionCard}>
            <Text style={appStyles.correctionTitle}>这句话可以更自然</Text>
            <Text style={appStyles.smallText}>你说：{latestCorrection.original}</Text>
            <Text style={[appStyles.smallText, { marginTop: 6 }]}>更自然：{latestCorrection.improved}</Text>
            <Text style={[appStyles.smallText, { marginTop: 6, marginBottom: 12 }]}>{latestCorrection.reason}</Text>
            <View style={[appStyles.row, { gap: 8 }]}>
              <Pressable style={[appStyles.secondaryButton, { flex: 1 }]} onPress={openGrammarCoach}>
                <Text style={appStyles.secondaryButtonText}>详细解释</Text>
              </Pressable>
              <Pressable style={[appStyles.primaryButton, { flex: 1 }]} onPress={saveCorrectionToReview}>
                <Text style={appStyles.buttonText}>加入复习</Text>
              </Pressable>
            </View>
          </View>
        ) : null}

        <TextInput
          placeholder="用你正在学习的语言发一条消息..."
          value={draft}
          onChangeText={setDraft}
          style={appStyles.input}
          multiline
        />
        <Pressable style={[appStyles.primaryButton, { marginTop: 10 }]} onPress={sendMessage}>
          <Text style={appStyles.buttonText}>发送</Text>
        </Pressable>
      </View>
    </>
  );

  const renderTasksTab = () => (
    <>
      {tasks.map((task) => (
        <View key={task.id} style={appStyles.sectionCard}>
          <View style={appStyles.row}>
            <Text style={appStyles.agentName}>{task.title}</Text>
            <Text style={[appStyles.smallText, task.status === 'done' ? { color: palette.success } : null]}>
              {task.status === 'done' ? '已完成' : `${task.progress}/${task.target}`}
            </Text>
          </View>
          <Text style={[appStyles.smallText, { marginTop: 8 }]}>{task.detail}</Text>
        </View>
      ))}
    </>
  );

  const renderReviewTab = () => (
    <>
      {reviewCards.length === 0 ? (
        <View style={appStyles.sectionCard}>
          <Text style={appStyles.agentName}>你的复习卡片会从真实聊天中自动生成</Text>
          <Text style={[appStyles.smallText, { marginTop: 8 }]}>先去聊天里说几句，再把关键纠错加入复习。</Text>
        </View>
      ) : (
        reviewCards.map((card) => (
          <View key={card.id} style={appStyles.sectionCard}>
            <Text style={appStyles.agentName}>{card.title}</Text>
            <Text style={[appStyles.smallText, { marginTop: 8 }]}>错误句：{card.wrong}</Text>
            <Text style={[appStyles.smallText, { marginTop: 6 }]}>推荐表达：{card.correct}</Text>
            <Text style={[appStyles.smallText, { marginTop: 6, marginBottom: 12 }]}>{card.note}</Text>
            <Pressable
              style={card.status === 'mastered' ? appStyles.secondaryButton : appStyles.primaryButton}
              onPress={() => masterReviewCard(card.id)}
            >
              <Text style={card.status === 'mastered' ? appStyles.secondaryButtonText : appStyles.buttonText}>
                {card.status === 'mastered' ? '已掌握' : '我记住了'}
              </Text>
            </Pressable>
          </View>
        ))
      )}
    </>
  );

  const renderProfileTab = () => (
    <>
      <View style={appStyles.sectionCard}>
        <Text style={appStyles.agentName}>你的学习档案</Text>
        <Text style={[appStyles.smallText, { marginTop: 8 }]}>
          目标语言：{language} · 当前水平：{level} · 学习目标：{goal}
        </Text>
      </View>

      <View style={[appStyles.row, { gap: 10, marginBottom: 12 }]}>
        <View style={[appStyles.sectionCard, { flex: 1 }]}>
          <Text style={appStyles.smallText}>连续学习</Text>
          <Text style={appStyles.statValue}>{stats.streakDays} 天</Text>
        </View>
        <View style={[appStyles.sectionCard, { flex: 1 }]}>
          <Text style={appStyles.smallText}>消息总数</Text>
          <Text style={appStyles.statValue}>{stats.totalMessages}</Text>
        </View>
      </View>

      <View style={[appStyles.row, { gap: 10 }]}>
        <View style={[appStyles.sectionCard, { flex: 1 }]}>
          <Text style={appStyles.smallText}>复习卡片</Text>
          <Text style={appStyles.statValue}>{stats.correctionsSaved}</Text>
        </View>
        <View style={[appStyles.sectionCard, { flex: 1 }]}>
          <Text style={appStyles.smallText}>已掌握</Text>
          <Text style={appStyles.statValue}>{stats.reviewCardsMastered}</Text>
        </View>
      </View>
    </>
  );

  return (
    <SafeAreaView style={appStyles.safeArea}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={appStyles.root}>
        <View style={appStyles.content}>
          <View style={appStyles.heroCard}>
            <Text style={appStyles.eyebrow}>LingoChat Web MVP</Text>
            <Text style={appStyles.title}>像微信一样学习语言</Text>
            <Text style={appStyles.subtitle}>
              每个好友都是一个 AI Agent。聊天、纠错、任务和复习被收进同一个可在 Web 测试的体验里。
            </Text>
            {started ? (
              <View style={appStyles.ctaRow}>
                <Pressable style={appStyles.secondaryButton} onPress={resetDemo}>
                  <Text style={appStyles.secondaryButtonText}>重置体验</Text>
                </Pressable>
              </View>
            ) : null}
          </View>

          {!started ? (
            <>
              {renderOptionGroup('你想学哪种语言？', languageOptions, language, setLanguage)}
              {renderOptionGroup('你现在大概是什么水平？', levelOptions, level, setLevel)}
              {renderOptionGroup('你学这门语言主要是为了什么？', goalOptions, goal, setGoal)}
              <View style={appStyles.sectionCard}>
                <Text style={appStyles.agentName}>准备好了就开始第一段聊天</Text>
                <Text style={[appStyles.smallText, { marginTop: 8 }]}>
                  你的首个 AI 好友会根据上面的设置调整聊天难度和任务方向。
                </Text>
                <View style={appStyles.ctaRow}>
                  <Pressable style={appStyles.primaryButton} onPress={() => setStarted(true)}>
                    <Text style={appStyles.buttonText}>进入聊天</Text>
                  </Pressable>
                </View>
              </View>
            </>
          ) : (
            <>
              <View style={appStyles.tabRow}>
                {[
                  ['chat', '聊天'],
                  ['tasks', '任务'],
                  ['review', '复习'],
                  ['profile', '我的'],
                ].map(([key, label]) => {
                  const isActive = activeTab === key;
                  return (
                    <Pressable
                      key={key}
                      onPress={() => setActiveTab(key as TabKey)}
                      style={[appStyles.tabButton, isActive && appStyles.tabButtonActive]}
                    >
                      <Text style={[appStyles.tabLabel, isActive && appStyles.tabLabelActive]}>{label}</Text>
                    </Pressable>
                  );
                })}
              </View>

              {activeTab === 'chat' && renderChatTab()}
              {activeTab === 'tasks' && renderTasksTab()}
              {activeTab === 'review' && renderReviewTab()}
              {activeTab === 'profile' && renderProfileTab()}
            </>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
