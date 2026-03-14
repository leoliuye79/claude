import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { ChevronRight, Cpu, Moon, Info } from 'lucide-react';

export default function SettingsPage() {
  const darkMode = useStore((s) => s.darkMode);
  const toggleDarkMode = useStore((s) => s.toggleDarkMode);
  const aiConfig = useStore((s) => s.aiConfig);
  const navigate = useNavigate();

  return (
    <div className="flex-1 flex flex-col">
      <header className="px-4 py-3 border-b border-gray-100">
        <h1 className="text-lg font-bold">设置</h1>
      </header>

      <div className="flex-1 overflow-y-auto">
        <div className="px-4 py-2 text-xs text-gray-400 font-medium mt-2">AI 配置</div>
        <button
          onClick={() => navigate('/settings/ai-model')}
          className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-gray-50 transition-colors"
        >
          <Cpu size={20} className="text-primary" />
          <div className="flex-1 text-left">
            <p className="text-[15px]">AI 模型设置</p>
            <p className="text-xs text-gray-400 mt-0.5">
              {aiConfig.provider === 'claude' ? 'Claude' : 'OpenAI'} · {aiConfig.apiKey ? '已配置' : '未配置'}
            </p>
          </div>
          <ChevronRight size={18} className="text-gray-300" />
        </button>

        <div className="px-4 py-2 text-xs text-gray-400 font-medium mt-2">外观</div>
        <div className="flex items-center gap-3 px-4 py-3.5">
          <Moon size={20} className="text-primary" />
          <span className="flex-1 text-[15px]">深色模式</span>
          <button
            onClick={toggleDarkMode}
            className={`w-12 h-7 rounded-full transition-colors ${darkMode ? 'bg-primary' : 'bg-gray-200'}`}
          >
            <div className={`w-5 h-5 rounded-full bg-white shadow transition-transform mx-1 ${darkMode ? 'translate-x-5' : ''}`} />
          </button>
        </div>

        <div className="px-4 py-2 text-xs text-gray-400 font-medium mt-2">关于</div>
        <div className="flex items-center gap-3 px-4 py-3.5">
          <Info size={20} className="text-primary" />
          <div className="flex-1">
            <p className="text-[15px]">LangBuddy</p>
            <p className="text-xs text-gray-400 mt-0.5">v2.0.0 · React + Capacitor</p>
          </div>
        </div>
      </div>
    </div>
  );
}
