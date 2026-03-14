import { useState } from 'react';
import { Send, Mic } from 'lucide-react';

interface ChatInputProps {
  onSend: (text: string) => void;
  disabled?: boolean;
}

export default function ChatInput({ onSend, disabled }: ChatInputProps) {
  const [text, setText] = useState('');

  const handleSend = () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onSend(trimmed);
    setText('');
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="flex items-end gap-2 p-3 border-t border-gray-100 bg-white">
      <button className="p-2 text-gray-400 hover:text-primary transition-colors">
        <Mic size={22} />
      </button>
      <div className="flex-1 relative">
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="输入消息..."
          rows={1}
          disabled={disabled}
          className="w-full resize-none rounded-2xl border border-gray-200 px-4 py-2.5 text-[15px] outline-none focus:border-primary transition-colors disabled:opacity-50"
          style={{ maxHeight: 120 }}
        />
      </div>
      <button
        onClick={handleSend}
        disabled={!text.trim() || disabled}
        className="p-2 text-primary disabled:text-gray-300 transition-colors"
      >
        <Send size={22} />
      </button>
    </div>
  );
}
