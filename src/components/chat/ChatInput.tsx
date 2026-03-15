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

  const hasText = text.trim().length > 0;

  return (
    <div className="px-3 py-3 bg-white dark:bg-[#12121A] border-t border-gray-100/50 dark:border-gray-800/30 relative">
      {micTip && (
        <div className="absolute -top-10 left-4 bg-gray-800 dark:bg-gray-700 text-white text-xs px-3.5 py-2 rounded-xl shadow-lg animate-fade-in">
          语音功能即将上线
          <div className="absolute bottom-0 left-5 translate-y-1/2 rotate-45 w-2 h-2 bg-gray-800 dark:bg-gray-700" />
        </div>
      )}
      <div className="flex items-end gap-2">
        <button
          onClick={handleMic}
          className="w-10 h-10 rounded-xl flex items-center justify-center text-gray-400 hover:text-primary hover:bg-primary/10 transition-all shrink-0"
        >
          <Mic size={20} />
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
            className="w-full resize-none rounded-2xl bg-surface-dim dark:bg-gray-800 px-4 py-2.5 text-[15px] outline-none border border-transparent focus:border-primary/30 input-focus-glow dark:text-gray-100 transition-all disabled:opacity-50 placeholder:text-gray-400"
            style={{ maxHeight: 120 }}
          />
        </div>
        <button
          onClick={handleSend}
          disabled={!hasText || disabled}
          className={`w-10 h-10 rounded-xl flex items-center justify-center transition-all shrink-0 ${
            hasText && !disabled
              ? 'gradient-primary text-white shadow-sm shadow-primary/30 active:scale-95'
              : 'bg-gray-100 dark:bg-gray-800 text-gray-300 dark:text-gray-600'
          }`}
        >
          <Send size={18} />
        </button>
      </div>
    </div>
  );
}
