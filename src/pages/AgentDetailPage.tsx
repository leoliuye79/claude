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
    <div className="flex-1 flex flex-col bg-white dark:bg-[#12121A]">
      {/* Header with gradient background */}
      <div className="gradient-primary pb-16 pt-3 px-3 relative">
        <button
          onClick={() => navigate(-1)}
          className="w-8 h-8 rounded-xl flex items-center justify-center text-white/80 hover:bg-white/10 transition-colors"
        >
          <ChevronLeft size={22} />
        </button>
      </div>

      {/* Profile card overlapping header */}
      <div className="flex-1 overflow-y-auto -mt-12 relative">
        <div className="mx-4 bg-white dark:bg-gray-800/50 rounded-3xl shadow-lg dark:shadow-none px-5 pt-12 pb-5 relative mb-4">
          {/* Avatar centered on top */}
          <div className="absolute -top-8 left-1/2 -translate-x-1/2">
            <Avatar name={agent.name} size="xl" />
          </div>

          <div className="text-center mb-5">
            <h2 className="text-xl font-bold dark:text-white">{agent.nameZh}</h2>
            <p className="text-[13px] text-gray-400 dark:text-gray-500 mt-0.5">{agent.name}</p>
          </div>

          <div className="grid grid-cols-4 gap-2">
            {info.map((item) => (
              <div key={item.label} className="bg-surface-dim dark:bg-gray-700/50 rounded-xl p-2.5 text-center">
                <p className="text-[10px] text-gray-400 dark:text-gray-500 font-medium mb-0.5">{item.label}</p>
                <p className="text-[12px] font-semibold dark:text-gray-200 truncate">{item.value}</p>
              </div>
            ))}
          </div>
        </div>

        <div className="px-5 space-y-5 pb-24">
          <section>
            <h3 className="text-[12px] font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-2">性格</h3>
            <p className="text-[14px] text-gray-600 dark:text-gray-300 leading-relaxed">{agent.personality}</p>
          </section>

          <section>
            <h3 className="text-[12px] font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-2">话题</h3>
            <div className="flex flex-wrap gap-2">
              {agent.topics.map((t) => (
                <span key={t} className="text-[12px] bg-surface-dim dark:bg-gray-800 text-gray-600 dark:text-gray-300 px-3 py-1.5 rounded-lg font-medium">
                  {t}
                </span>
              ))}
            </div>
          </section>

          <section>
            <h3 className="text-[12px] font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-2">打招呼</h3>
            <div className="bg-surface-dim dark:bg-gray-800 rounded-2xl p-4">
              <p className="text-[14px] text-gray-600 dark:text-gray-300 italic leading-relaxed">"{agent.greeting}"</p>
            </div>
          </section>
        </div>
      </div>

      {/* Floating button */}
      <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-white dark:from-[#12121A] via-white/80 dark:via-[#12121A]/80 to-transparent pt-12">
        <button
          onClick={handleStartChat}
          className="w-full gradient-primary text-white py-3.5 rounded-2xl font-semibold flex items-center justify-center gap-2 shadow-lg shadow-primary/25 active:scale-[0.98] transition-transform"
        >
          <MessageCircle size={18} />
          开始聊天
        </button>
      </div>
    </div>
  );
}
