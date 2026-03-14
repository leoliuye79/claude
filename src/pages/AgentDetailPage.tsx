import { useParams, useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { ROLE_LABELS } from '@/types';
import { ChevronLeft, MessageCircle } from 'lucide-react';

export default function AgentDetailPage() {
  const { agentId } = useParams<{ agentId: string }>();
  const navigate = useNavigate();
  const agents = useStore((s) => s.agents);
  const conversations = useStore((s) => s.conversations);
  const createConversation = useStore((s) => s.createConversation);

  const agent = agents.find((a) => a.id === agentId);
  if (!agent) return <div className="flex-1 flex items-center justify-center text-gray-400">未找到</div>;

  const handleStartChat = () => {
    // Check if there's an existing conversation with this agent
    const existing = conversations.find((c) => c.agentId === agent.id);
    if (existing) {
      navigate(`/chat/${existing.id}`, { replace: true });
    } else {
      const convId = createConversation(agent.id);
      navigate(`/chat/${convId}`, { replace: true });
    }
  };

  const info = [
    { label: '角色', value: ROLE_LABELS[agent.role] },
    { label: '级别', value: agent.targetLevel },
    { label: '风格', value: agent.style },
    { label: '纠错', value: agent.correctionMode },
  ];

  return (
    <div className="flex-1 flex flex-col bg-white dark:bg-gray-900 dark:text-gray-100">
      <header className="flex items-center gap-2 px-2 py-2.5 border-b border-gray-100 dark:border-gray-800">
        <button onClick={() => navigate(-1)} className="p-1 text-gray-600">
          <ChevronLeft size={24} />
        </button>
        <span className="font-medium">伙伴详情</span>
      </header>

      <div className="flex-1 overflow-y-auto">
        <div className="flex flex-col items-center pt-8 pb-6">
          <Avatar name={agent.name} size="lg" />
          <h2 className="text-xl font-bold mt-3">{agent.nameZh}</h2>
          <p className="text-sm text-gray-400">{agent.name}</p>
        </div>

        <div className="grid grid-cols-4 gap-2 px-4 mb-6">
          {info.map((item) => (
            <div key={item.label} className="bg-gray-50 dark:bg-gray-800 rounded-xl p-3 text-center">
              <p className="text-xs text-gray-400 mb-1">{item.label}</p>
              <p className="text-sm font-medium">{item.value}</p>
            </div>
          ))}
        </div>

        <div className="px-4 mb-4">
          <h3 className="text-sm font-medium text-gray-500 mb-2">性格</h3>
          <p className="text-sm text-gray-600 leading-relaxed">{agent.personality}</p>
        </div>

        <div className="px-4 mb-4">
          <h3 className="text-sm font-medium text-gray-500 mb-2">话题</h3>
          <div className="flex flex-wrap gap-2">
            {agent.topics.map((t) => (
              <span key={t} className="text-xs bg-gray-100 text-gray-600 px-3 py-1 rounded-full">{t}</span>
            ))}
          </div>
        </div>

        <div className="px-4 mb-6">
          <h3 className="text-sm font-medium text-gray-500 mb-2">打招呼</h3>
          <p className="text-sm text-gray-600 dark:text-gray-300 bg-gray-50 dark:bg-gray-800 rounded-xl p-3 italic">"{agent.greeting}"</p>
        </div>
      </div>

      <div className="p-4">
        <button
          onClick={handleStartChat}
          className="w-full bg-primary text-white py-3 rounded-full font-medium flex items-center justify-center gap-2 hover:bg-primary-dark transition-colors"
        >
          <MessageCircle size={18} />
          开始聊天
        </button>
      </div>
    </div>
  );
}
