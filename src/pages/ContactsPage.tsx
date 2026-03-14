import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { ROLE_LABELS } from '@/types';
import { UserPlus } from 'lucide-react';

export default function ContactsPage() {
  const agents = useStore((s) => s.agents);
  const navigate = useNavigate();

  const builtIn = agents.filter((a) => !a.isCustom);
  const custom = agents.filter((a) => a.isCustom);

  return (
    <div className="flex-1 flex flex-col">
      <header className="flex items-center justify-between px-4 py-3 border-b border-gray-100 dark:border-gray-800">
        <h1 className="text-lg font-bold">伙伴</h1>
        <button onClick={() => navigate('/custom-agent')} className="p-2 text-primary">
          <UserPlus size={20} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto">
        <div className="px-4 py-2 text-xs text-gray-400 font-medium">默认伙伴</div>
        {builtIn.map((agent) => (
          <AgentRow key={agent.id} agent={agent} onClick={() => navigate(`/agent/${agent.id}`)} />
        ))}

        {custom.length > 0 && (
          <>
            <div className="px-4 py-2 text-xs text-gray-400 font-medium mt-2">自定义伙伴</div>
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
      className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800 cursor-pointer active:bg-gray-100 dark:active:bg-gray-700 transition-colors"
      onClick={onClick}
    >
      <Avatar name={agent.name} />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="font-medium text-[15px]">{agent.nameZh}</span>
          <span className="text-xs text-gray-400">{agent.name}</span>
        </div>
        <div className="flex items-center gap-2 mt-0.5">
          <span className="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full">
            {ROLE_LABELS[agent.role]}
          </span>
          <span className="text-xs text-gray-400">{agent.targetLevel}</span>
        </div>
      </div>
    </div>
  );
}
