import { useRef, useState } from 'react';
import { Send, Mic } from 'lucide-react';

interface ChatInputProps {
  onSend: (text: string) => void;
  disabled?: boolean;
}

export default function ChatInput({ onSend, disabled }: ChatInputProps) {
  const [text, setText] = useState('');
  const [micTip, setMicTip] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleSend = () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onSend(trimmed);
    setText('');
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleInput = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
    const el = e.target;
    el.style.height = 'auto';
    el.style.height = `${Math.min(el.scrollHeight, 120)}px`;
  };

  const handleMic = () => {
    setMicTip(true);
    setTimeout(() => setMicTip(false), 2000);
  };

  return (
    <div className="flex items-end gap-2 p-3 border-t border-gray-100 dark:border-gray-800 bg-white dark:bg-gray-900 relative">
      {micTip && (
        <div className="absolute -top-8 left-3 bg-gray-800 text-white text-xs px-3 py-1 rounded-full">
          语音功能即将上线
        </div>
      )}
      <button onClick={handleMic} className="p-2 text-gray-400 hover:text-primary transition-colors">
        <Mic size={22} />
      </button>
      <div className="flex-1 relative">
        <textarea
          ref={textareaRef}
          value={text}
          onChange={handleInput}
          onKeyDown={handleKeyDown}
          placeholder="输入消息..."
          rows={1}
          disabled={disabled}
          className="w-full resize-none rounded-2xl border border-gray-200 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-4 py-2.5 text-[15px] outline-none focus:border-primary transition-colors disabled:opacity-50"
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
