import { useEffect, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import ChatBubble from '@/components/chat/ChatBubble';
import ChatInput from '@/components/chat/ChatInput';
import Avatar from '@/components/common/Avatar';
import { ChevronLeft } from 'lucide-react';

export default function ChatPage() {
  const { conversationId } = useParams<{ conversationId: string }>();
  const navigate = useNavigate();
  const conversations = useStore((s) => s.conversations);
  const agents = useStore((s) => s.agents);
  const messages = useStore((s) => s.messages);
  const sendMessage = useStore((s) => s.sendMessage);
  const [sending, setSending] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  const conv = conversations.find((c) => c.id === conversationId);
  const agent = agents.find((a) => a.id === conv?.agentId);
  const convMessages = messages.filter((m) => m.conversationId === conversationId);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [convMessages.length]);

  const handleSend = async (text: string) => {
    if (!conversationId) return;
    setSending(true);
    await sendMessage(conversationId, text);
    setSending(false);
  };

  if (!conv || !agent) {
    return (
      <div className="flex-1 flex items-center justify-center bg-white dark:bg-[#12121A]">
        <p className="text-gray-400">对话不存在</p>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col h-dvh bg-surface-dim dark:bg-[#12121A]">
      {/* Header */}
      <header className="flex items-center gap-3 px-3 py-3 bg-white/90 dark:bg-[#12121A]/90 glass shrink-0 border-b border-gray-100/50 dark:border-gray-800/30">
        <button
          onClick={() => navigate(-1)}
          className="w-8 h-8 rounded-xl flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
        >
          <ChevronLeft size={22} />
        </button>
        <Avatar name={agent.name} size="sm" />
        <div className="flex-1 min-w-0">
          <h2 className="text-[15px] font-semibold leading-tight dark:text-white">{agent.nameZh}</h2>
          <p className="text-[11px] text-gray-400 dark:text-gray-500">{agent.name}</p>
        </div>
      </header>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4">
        {convMessages.map((msg) => (
          <ChatBubble key={msg.id} message={msg} agentName={agent.nameZh} />
        ))}
        {sending && (
          <div className="flex items-start mb-3 animate-fade-in">
            <div className="bg-white dark:bg-gray-800 rounded-2xl rounded-bl-md px-4 py-3 shadow-sm">
              <div className="flex gap-1.5">
                <span className="w-2 h-2 bg-gray-300 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                <span className="w-2 h-2 bg-gray-300 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                <span className="w-2 h-2 bg-gray-300 dark:bg-gray-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
              </div>
            </div>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <ChatInput onSend={handleSend} disabled={sending} />
    </div>
  );
}
