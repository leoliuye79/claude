import type { Message } from '@/types';
import { formatChatTime } from '@/utils/dateFormatter';
import CorrectionBubble from './CorrectionBubble';

interface ChatBubbleProps {
  message: Message;
  agentName?: string;
}

export default function ChatBubble({ message, agentName }: ChatBubbleProps) {
  const isUser = message.sender === 'user';

  if (message.type === 'systemNotice') {
    return (
      <div className="flex justify-center my-2">
        <span className="text-xs text-red-500 bg-red-50 px-3 py-1 rounded-full">{message.content}</span>
      </div>
    );
  }

  return (
    <div className={`flex flex-col mb-3 ${isUser ? 'items-end' : 'items-start'}`}>
      {!isUser && agentName && (
        <span className="text-xs text-gray-400 ml-1 mb-1">{agentName}</span>
      )}
      <div
        className={`max-w-[80%] px-3.5 py-2.5 rounded-2xl text-[15px] leading-relaxed whitespace-pre-wrap ${
          isUser
            ? 'bg-primary text-white rounded-br-md'
            : 'bg-gray-100 text-gray-800 rounded-bl-md'
        }`}
      >
        {message.content}
      </div>
      {message.correction && <CorrectionBubble correction={message.correction} />}
      <span className="text-[11px] text-gray-400 mt-1 mx-1">
        {formatChatTime(message.createdAt)}
      </span>
    </div>
  );
}
