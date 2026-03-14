import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { ROLE_LABELS } from '@/types';
import { ChevronRight } from 'lucide-react';

const SCENARIOS = [
  { title: '日常对话', desc: '练习日常英语交流', agentId: 'agent_friend_jake', emoji: '💬', gradient: 'from-blue-500 to-cyan-400' },
  { title: '面试准备', desc: '模拟英语面试场景', agentId: 'agent_coach_rachel', emoji: '💼', gradient: 'from-violet-500 to-purple-400' },
  { title: '旅行英语', desc: '学习旅行常用表达', agentId: 'agent_travel_sam', emoji: '✈️', gradient: 'from-amber-500 to-orange-400' },
  { title: '商务邮件', desc: '练习专业邮件写作', agentId: 'agent_colleague_linda', emoji: '📧', gradient: 'from-emerald-500 to-teal-400' },
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
      <header className="px-5 pt-5 pb-3">
        <h1 className="text-[22px] font-bold tracking-tight">发现</h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-2">
        <h2 className="text-[12px] font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-3 px-1">
          热门场景
        </h2>
        <div className="grid grid-cols-2 gap-3 mb-8">
          {SCENARIOS.map((s) => (
            <button
              key={s.agentId}
              onClick={() => handleStartScenario(s.agentId)}
              className="bg-white dark:bg-gray-800/50 rounded-2xl p-4 text-left hover:shadow-md dark:hover:bg-gray-800 transition-all active:scale-[0.98] border border-gray-100/80 dark:border-gray-700/30"
            >
              <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${s.gradient} flex items-center justify-center text-lg mb-3`}>
                {s.emoji}
              </div>
              <h3 className="font-semibold text-[14px] mb-0.5 dark:text-white">{s.title}</h3>
              <p className="text-[12px] text-gray-400 dark:text-gray-500 leading-snug">{s.desc}</p>
            </button>
          ))}
        </div>

        <h2 className="text-[12px] font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-3 px-1">
          推荐伙伴
        </h2>
        <div className="space-y-2.5">
          {agents.filter((a) => !a.isCustom).slice(0, 3).map((agent) => (
            <div
              key={agent.id}
              onClick={() => navigate(`/agent/${agent.id}`)}
              className="flex items-center gap-3.5 bg-white dark:bg-gray-800/50 rounded-2xl p-3.5 cursor-pointer hover:shadow-md dark:hover:bg-gray-800 transition-all active:scale-[0.99] border border-gray-100/80 dark:border-gray-700/30"
            >
              <Avatar name={agent.name} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="font-semibold text-[14px] dark:text-white">{agent.nameZh}</span>
                  <span className="text-[11px] font-medium bg-primary/10 text-primary px-2 py-0.5 rounded-md">
                    {ROLE_LABELS[agent.role]}
                  </span>
                </div>
                <p className="text-[12px] text-gray-400 dark:text-gray-500 truncate leading-snug">{agent.personality}</p>
              </div>
              <ChevronRight size={16} className="text-gray-300 dark:text-gray-600 shrink-0" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
