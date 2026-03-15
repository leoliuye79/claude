import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { ROLE_LABELS } from '@/types';
import { UserPlus, ChevronRight } from 'lucide-react';

export default function ContactsPage() {
  const agents = useStore((s) => s.agents);
  const navigate = useNavigate();

  const builtIn = agents.filter((a) => !a.isCustom);
  const custom = agents.filter((a) => a.isCustom);

  return (
    <div className="flex-1 flex flex-col">
      <header className="px-5 pt-5 pb-3">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold tracking-tight">伙伴</h1>
          <button
            onClick={() => navigate('/custom-agent')}
            className="w-11 h-11 rounded-xl bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 active:scale-95 transition-all"
          >
            <UserPlus size={18} strokeWidth={2.2} />
          </button>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto px-3">
        <div className="px-2 py-2 text-xs text-gray-400 dark:text-gray-500 font-semibold uppercase tracking-wider">
          默认伙伴
        </div>
        {builtIn.map((agent) => (
          <AgentRow key={agent.id} agent={agent} onClick={() => navigate(`/agent/${agent.id}`)} />
        ))}

        {custom.length > 0 && (
          <>
            <div className="px-2 py-2 text-xs text-gray-400 dark:text-gray-500 font-semibold uppercase tracking-wider mt-3">
              自定义伙伴
            </div>
            {custom.map((agent) => (
              <AgentRow key={agent.id} agent={agent} onClick={() => navigate(`/agent/${agent.id}`)} />
            ))}
          </>
        )}
      </div>
    </div>
  );
}

function AgentRow({ agent, onClick }: { agent: ReturnType<typeof useStore.getState>['agents'][0]; onClick: () => void }) {
  return (
    <div
      className="flex items-center gap-3 px-3 py-3 rounded-2xl hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer active:bg-gray-100 dark:active:bg-white/10 transition-all"
      onClick={onClick}
    >
      <Avatar name={agent.name} />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-0.5">
          <span className="font-semibold text-base">{agent.nameZh}</span>
          <span className="text-xs text-gray-400 dark:text-gray-500">{agent.name}</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs font-medium bg-primary/10 text-primary px-2 py-0.5 rounded-md">
            {ROLE_LABELS[agent.role]}
          </span>
          <span className="text-xs text-gray-400 dark:text-gray-500 font-medium">{agent.targetLevel}</span>
        </div>
      </div>
      <ChevronRight size={16} className="text-gray-300 dark:text-gray-600 opacity-40" />
    </div>
  );
}
