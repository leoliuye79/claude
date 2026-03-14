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
      <div className="flex-1 flex items-center justify-center">
        <p className="text-gray-400">对话不存在</p>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col h-dvh">
      {/* Header */}
      <header className="flex items-center gap-3 px-2 py-2.5 border-b border-gray-100 bg-white shrink-0">
        <button onClick={() => navigate(-1)} className="p-1 text-gray-600">
          <ChevronLeft size={24} />
        </button>
        <Avatar name={agent.name} size="sm" />
        <div>
          <h2 className="text-[15px] font-medium leading-tight">{agent.nameZh}</h2>
          <p className="text-xs text-gray-400">{agent.name}</p>
        </div>
      </header>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-3">
        {convMessages.map((msg) => (
          <ChatBubble key={msg.id} message={msg} agentName={agent.nameZh} />
        ))}
        {sending && (
          <div className="flex items-start mb-3">
            <div className="bg-gray-100 rounded-2xl rounded-bl-md px-4 py-3">
              <div className="flex gap-1">
                <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
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
