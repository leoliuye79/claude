import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import Avatar from '@/components/common/Avatar';
import { formatConversationTime } from '@/utils/dateFormatter';
import { Plus, Trash2, Pin, MessageCircle } from 'lucide-react';

export default function ConversationsPage() {
  const conversations = useStore((s) => s.conversations);
  const agents = useStore((s) => s.agents);
  const deleteConversation = useStore((s) => s.deleteConversation);
  const pinConversation = useStore((s) => s.pinConversation);
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
      {/* Header */}
      <header className="px-5 pt-5 pb-3">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold tracking-tight">对话</h1>
          <button
            onClick={() => navigate('/contacts')}
            className="w-11 h-11 rounded-xl bg-primary/10 text-primary flex items-center justify-center hover:bg-primary/20 active:scale-95 transition-all"
          >
            <Plus size={20} strokeWidth={2.5} />
          </button>
        </div>
      </header>

      {sorted.length === 0 ? (
        <div className="flex-1 flex flex-col items-center justify-center px-8">
          <div className="w-20 h-20 rounded-3xl bg-primary/5 dark:bg-primary/10 flex items-center justify-center mb-5 shadow-float">
            <MessageCircle size={36} className="text-primary/70" strokeWidth={1.5} />
          </div>
          <p className="text-on-surface-secondary text-base font-medium mb-1">还没有对话</p>
          <p className="text-gray-400 dark:text-gray-500 text-sm mb-5">选择一个伙伴，开始练习英语吧</p>
          <button
            onClick={() => navigate('/contacts')}
            className="text-white text-sm font-medium px-6 py-2.5 rounded-full gradient-primary shadow-sm shadow-primary/25 hover:shadow-card-hover active:scale-[0.97] transition-all"
          >
            选择伙伴开始聊天
          </button>
        </div>
      ) : (
        <div className="flex-1 overflow-y-auto px-3">
          {sorted.map((conv) => {
            const agent = agentMap[conv.agentId];
            if (!agent) return null;
            return (
              <div
                key={conv.id}
                className="flex items-center gap-3 px-3 py-3 rounded-2xl hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer active:bg-gray-100 dark:active:bg-white/10 transition-all"
                onClick={() => navigate(`/chat/${conv.id}`)}
              >
                <Avatar name={agent.name} />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-0.5">
                    <span className="font-semibold text-base flex items-center gap-1.5">
                      {agent.nameZh}
                      {conv.isPinned && <Pin size={12} className="text-primary fill-primary" />}
                    </span>
                    <span className="text-xs text-gray-400 dark:text-gray-500 font-medium">
                      {conv.lastMessageAt && formatConversationTime(conv.lastMessageAt)}
                    </span>
                  </div>
                  <p className="text-sm text-gray-400 dark:text-gray-500 truncate leading-snug">
                    {conv.lastMessagePreview ?? ''}
                  </p>
                </div>
                {/* Actions */}
                <div className="flex gap-1 opacity-60">
                  <button
                    onClick={(e) => { e.stopPropagation(); pinConversation(conv.id); }}
                    className={`p-2.5 rounded-lg transition-colors ${conv.isPinned ? 'text-primary' : 'text-gray-300 hover:text-primary'}`}
                  >
                    <Pin size={16} />
                  </button>
                  <button
                    onClick={(e) => { e.stopPropagation(); deleteConversation(conv.id); }}
                    className="p-2.5 rounded-lg text-gray-300 hover:text-danger transition-colors"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
