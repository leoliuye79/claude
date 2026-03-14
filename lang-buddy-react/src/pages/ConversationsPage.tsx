import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { formatConversationTime } from '@/utils/dateFormatter';
import { Plus } from 'lucide-react';

export default function ConversationsPage() {
  const conversations = useStore((s) => s.conversations);
  const agents = useStore((s) => s.agents);
  const deleteConversation = useStore((s) => s.deleteConversation);
  const navigate = useNavigate();

  const sorted = [...conversations].sort((a, b) => {
    if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
    const aTime = a.lastMessageAt ?? a.createdAt;
    const bTime = b.lastMessageAt ?? b.createdAt;
    return bTime.localeCompare(aTime);
  });

  const agentMap = Object.fromEntries(agents.map((a) => [a.id, a]));

  return (
    <div className="flex-1 flex flex-col">
      <header className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
        <h1 className="text-lg font-bold">对话</h1>
        <button onClick={() => navigate('/contacts')} className="p-2 text-primary">
          <Plus size={22} />
        </button>
      </header>

      {sorted.length === 0 ? (
        <div className="flex-1 flex flex-col items-center justify-center text-gray-400">
          <p className="mb-2">还没有对话</p>
          <button onClick={() => navigate('/contacts')} className="text-primary text-sm">
            选择一个伙伴开始聊天
          </button>
        </div>
      ) : (
        <div className="flex-1 overflow-y-auto">
          {sorted.map((conv) => {
            const agent = agentMap[conv.agentId];
            if (!agent) return null;
            return (
              <div
                key={conv.id}
                className="flex items-center gap-3 px-4 py-3 hover:bg-gray-50 cursor-pointer active:bg-gray-100 transition-colors"
                onClick={() => navigate(`/chat/${conv.id}`)}
              >
                <Avatar name={agent.name} />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-[15px]">
                      {agent.nameZh}
                      {conv.isPinned && <span className="ml-1 text-xs text-primary">📌</span>}
                    </span>
                    <span className="text-xs text-gray-400">
                      {conv.lastMessageAt && formatConversationTime(conv.lastMessageAt)}
                    </span>
                  </div>
                  <p className="text-sm text-gray-400 truncate mt-0.5">
                    {conv.lastMessagePreview ?? ''}
                  </p>
                </div>
                <button
                  onClick={(e) => { e.stopPropagation(); deleteConversation(conv.id); }}
                  className="text-xs text-gray-300 hover:text-red-400 ml-1 shrink-0"
                >
                  ✕
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
