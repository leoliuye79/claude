import type { Message } from '@/types';
import { formatChatTime } from '@/utils/dateFormatter';
import CorrectionBubble from './CorrectionBubble';
import { AlertCircle } from 'lucide-react';

interface ChatBubbleProps {
  message: Message;
  agentName?: string;
}

export default function ChatBubble({ message, agentName }: ChatBubbleProps) {
  const isUser = message.sender === 'user';

  if (message.type === 'systemNotice') {
    return (
      <div className="flex justify-center my-3">
        <span className="inline-flex items-center gap-1.5 text-xs text-danger bg-danger/10 px-3.5 py-1.5 rounded-full font-medium">
          <AlertCircle size={12} />
          {message.content}
        </span>
      </div>
    );
  }

  return (
    <div className={`flex flex-col mb-4 ${isUser ? 'items-end' : 'items-start'}`}>
      {!isUser && agentName && (
        <span className="text-[11px] text-gray-400 dark:text-gray-500 ml-1 mb-1.5 font-medium">{agentName}</span>
      )}
      <div
        className={`max-w-[80%] px-4 py-3 text-[15px] leading-relaxed whitespace-pre-wrap ${
          isUser
            ? 'gradient-primary text-white rounded-2xl rounded-br-sm shadow-sm shadow-primary/20'
            : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 rounded-2xl rounded-bl-sm shadow-sm'
        }`}
      >
        {message.content}
      </div>
      {message.correction && <CorrectionBubble correction={message.correction} />}
      <span className="text-[11px] text-gray-300 dark:text-gray-600 mt-1.5 mx-1 font-medium">
        {formatChatTime(message.createdAt)}
      </span>
    </div>
  );
}
