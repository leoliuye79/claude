import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { ROLE_LABELS } from '@/types';

const SCENARIOS = [
  { title: '日常对话', desc: '练习日常英语交流', agentId: 'agent_friend_jake', emoji: '💬' },
  { title: '面试准备', desc: '模拟英语面试场景', agentId: 'agent_coach_rachel', emoji: '💼' },
  { title: '旅行英语', desc: '学习旅行常用表达', agentId: 'agent_travel_sam', emoji: '✈️' },
  { title: '商务邮件', desc: '练习专业邮件写作', agentId: 'agent_colleague_linda', emoji: '📧' },
];

export default function DiscoverPage() {
  const agents = useStore((s) => s.agents);
  const createConversation = useStore((s) => s.createConversation);
  const conversations = useStore((s) => s.conversations);
  const navigate = useNavigate();

  const handleStartScenario = (agentId: string) => {
    const existing = conversations.find((c) => c.agentId === agentId);
    if (existing) {
      navigate(`/chat/${existing.id}`);
    } else {
      const convId = createConversation(agentId);
      navigate(`/chat/${convId}`);
    }
  };

  return (
    <div className="flex-1 flex flex-col">
      <header className="px-4 py-3 border-b border-gray-100">
        <h1 className="text-lg font-bold">发现</h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4">
        <h2 className="text-sm font-medium text-gray-500 mb-3">热门场景</h2>
        <div className="grid grid-cols-2 gap-3 mb-6">
          {SCENARIOS.map((s) => (
            <button
              key={s.agentId}
              onClick={() => handleStartScenario(s.agentId)}
              className="bg-gray-50 rounded-2xl p-4 text-left hover:bg-gray-100 transition-colors"
            >
              <span className="text-2xl">{s.emoji}</span>
              <h3 className="font-medium text-sm mt-2">{s.title}</h3>
              <p className="text-xs text-gray-400 mt-1">{s.desc}</p>
            </button>
          ))}
        </div>

        <h2 className="text-sm font-medium text-gray-500 mb-3">推荐伙伴</h2>
        <div className="space-y-3">
          {agents.filter((a) => !a.isCustom).slice(0, 3).map((agent) => (
            <div
              key={agent.id}
              onClick={() => navigate(`/agent/${agent.id}`)}
              className="flex items-center gap-3 bg-gray-50 rounded-2xl p-3 cursor-pointer hover:bg-gray-100 transition-colors"
            >
              <Avatar name={agent.name} />
              <div className="flex-1 min-w-0">
                <span className="font-medium text-sm">{agent.nameZh}</span>
                <p className="text-xs text-gray-400 truncate">{agent.personality}</p>
              </div>
              <span className="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full shrink-0">
                {ROLE_LABELS[agent.role]}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
