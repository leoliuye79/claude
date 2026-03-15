import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { ChevronRight, Cpu, Moon, Info, Sparkles } from 'lucide-react';

export default function SettingsPage() {
  const darkMode = useStore((s) => s.darkMode);
  const toggleDarkMode = useStore((s) => s.toggleDarkMode);
  const aiConfig = useStore((s) => s.aiConfig);
  const navigate = useNavigate();

  const providerLabel = aiConfig.provider === 'claude' ? 'Claude' : aiConfig.provider === 'openai' ? 'OpenAI' : '自定义';

  return (
    <div className="flex-1 flex flex-col">
      <header className="px-5 pt-5 pb-3">
        <h1 className="text-xl font-bold tracking-tight">设置</h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-2">
        {/* AI Config section */}
        <div className="text-xs text-gray-400 dark:text-gray-500 font-semibold uppercase tracking-wider px-2 mb-2">
          AI 配置
        </div>
        <button
          onClick={() => navigate('/settings/ai-model')}
          className="w-full flex items-center gap-3.5 px-4 py-4 rounded-2xl bg-white dark:bg-dark-card border border-gray-100/80 dark:border-dark-border/30 shadow-card hover:shadow-card-hover dark:hover:bg-dark-card transition-all card-interactive mb-6"
        >
          <div className="w-10 h-10 rounded-xl gradient-primary flex items-center justify-center">
            <Cpu size={18} className="text-white" />
          </div>
          <div className="flex-1 text-left">
            <p className="text-base font-medium dark:text-white">AI 模型设置</p>
            <p className="text-xs text-gray-400 dark:text-gray-500 mt-0.5">
              {providerLabel} · {aiConfig.apiKey ? '已配置' : '未配置'}
            </p>
          </div>
          <ChevronRight size={16} className="text-gray-300 dark:text-gray-600" />
        </button>

        {/* Appearance section */}
        <div className="text-xs text-gray-400 dark:text-gray-500 font-semibold uppercase tracking-wider px-2 mb-2">
          外观
        </div>
        <div className="flex items-center gap-3.5 px-4 py-4 rounded-2xl bg-white dark:bg-dark-card border border-gray-100/80 dark:border-dark-border/30 shadow-card mb-6">
          <div className="w-10 h-10 rounded-xl gradient-primary flex items-center justify-center">
            <Moon size={18} className="text-white" />
          </div>
          <span className="flex-1 text-base font-medium dark:text-white">深色模式</span>
          <button
            onClick={toggleDarkMode}
            className={`w-[52px] h-[30px] rounded-full transition-all duration-300 relative ${
              darkMode ? 'bg-primary' : 'bg-gray-200 dark:bg-gray-700'
            }`}
          >
            <div
              className={`absolute top-[3px] w-6 h-6 rounded-full bg-white shadow-sm transition-all duration-300 ${
                darkMode ? 'left-[23px]' : 'left-[3px]'
              }`}
            />
          </button>
        </div>

        {/* About section */}
        <div className="text-xs text-gray-400 dark:text-gray-500 font-semibold uppercase tracking-wider px-2 mb-2">
          关于
        </div>
        <div className="flex items-center gap-3.5 px-4 py-4 rounded-2xl bg-white dark:bg-dark-card border border-gray-100/80 dark:border-dark-border/30 shadow-card">
          <div className="w-10 h-10 rounded-xl gradient-accent flex items-center justify-center">
            <Sparkles size={18} className="text-white" />
          </div>
          <div className="flex-1">
            <p className="text-base font-medium dark:text-white">LangBuddy</p>
            <p className="text-xs text-gray-400 dark:text-gray-500 mt-0.5">v2.0.0 · React + Capacitor</p>
          </div>
          <Info size={16} className="text-gray-300 dark:text-gray-600" />
        </div>
      </div>
    </div>
  );
}
