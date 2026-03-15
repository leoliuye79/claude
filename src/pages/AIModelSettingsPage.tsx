import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { ChevronLeft, Check, Circle, CircleCheck } from 'lucide-react';
import type { AIProvider } from '@/types';

const PROVIDERS: { id: AIProvider; label: string; models: string[] }[] = [
  { id: 'claude', label: 'Claude (Anthropic)', models: ['claude-sonnet-4-20250514', 'claude-haiku-4-5-20251001'] },
  { id: 'openai', label: 'OpenAI', models: ['gpt-4o', 'gpt-4o-mini'] },
  { id: 'custom', label: '自定义 (OpenAI 兼容)', models: [] },
];

export default function AIModelSettingsPage() {
  const navigate = useNavigate();
  const aiConfig = useStore((s) => s.aiConfig);
  const setAIConfig = useStore((s) => s.setAIConfig);

  const [provider, setProvider] = useState<AIProvider>(aiConfig.provider);
  const [apiKey, setApiKey] = useState(aiConfig.apiKey);
  const [model, setModel] = useState(aiConfig.model);
  const [baseUrl, setBaseUrl] = useState(aiConfig.baseUrl ?? '');

  const currentProvider = PROVIDERS.find((p) => p.id === provider)!;

  const handleSave = () => {
    setAIConfig({ provider, apiKey, model, baseUrl: baseUrl || undefined });
    navigate(-1);
  };

  return (
    <div className="flex-1 flex flex-col bg-white dark:bg-dark-surface">
      <header className="flex items-center gap-2 px-3 py-3 border-b border-gray-100/50 dark:border-dark-border/30">
        <button
          onClick={() => navigate(-1)}
          className="w-11 h-11 rounded-xl flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
        >
          <ChevronLeft size={22} />
        </button>
        <span className="font-semibold flex-1 dark:text-white">AI 模型设置</span>
        <button
          onClick={handleSave}
          className="w-11 h-11 rounded-xl flex items-center justify-center text-primary hover:bg-primary/10 transition-colors"
        >
          <Check size={20} strokeWidth={2.5} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-5 py-5 space-y-6">
        <div>
          <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-3">
            提供商
          </label>
          <div className="space-y-2">
            {PROVIDERS.map((p) => (
              <button
                key={p.id}
                onClick={() => { setProvider(p.id); if (p.models.length) setModel(p.models[0]); }}
                className={`w-full flex items-center gap-3 text-left px-4 py-3.5 rounded-2xl border transition-all ${
                  provider === p.id
                    ? 'border-primary bg-primary/5 dark:bg-primary/10'
                    : 'border-gray-100 dark:border-dark-border hover:border-gray-200 dark:hover:border-dark-border'
                }`}
              >
                {provider === p.id ? (
                  <CircleCheck size={22} className="text-primary shrink-0" />
                ) : (
                  <Circle size={22} className="text-gray-300 dark:text-gray-600 shrink-0" />
                )}
                <span className="text-base font-medium dark:text-white">{p.label}</span>
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-3">
            API Key
          </label>
          <input
            type="password"
            value={apiKey}
            onChange={(e) => setApiKey(e.target.value)}
            placeholder={provider === 'claude' ? 'sk-ant-...' : 'sk-...'}
            className="w-full px-4 py-3.5 rounded-2xl bg-surface-dim dark:bg-dark-card text-base outline-none border border-transparent focus:border-primary/30 input-focus-glow transition-all dark:text-white"
          />
        </div>

        {currentProvider.models.length > 0 && (
          <div>
            <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-3">
              模型
            </label>
            <div className="space-y-2">
              {currentProvider.models.map((m) => (
                <button
                  key={m}
                  onClick={() => setModel(m)}
                  className={`w-full flex items-center gap-3 text-left px-4 py-3.5 rounded-2xl border transition-all ${
                    model === m
                      ? 'border-primary bg-primary/5 dark:bg-primary/10'
                      : 'border-gray-100 dark:border-dark-border hover:border-gray-200 dark:hover:border-dark-border'
                  }`}
                >
                  {model === m ? (
                    <CircleCheck size={22} className="text-primary shrink-0" />
                  ) : (
                    <Circle size={22} className="text-gray-300 dark:text-gray-600 shrink-0" />
                  )}
                  <span className="text-sm font-mono font-medium dark:text-gray-200">{m}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {provider === 'custom' && (
          <>
            <div>
              <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-3">
                模型名称
              </label>
              <input
                type="text"
                value={model}
                onChange={(e) => setModel(e.target.value)}
                placeholder="model-name"
                className="w-full px-4 py-3.5 rounded-2xl bg-surface-dim dark:bg-dark-card text-base outline-none border border-transparent focus:border-primary/30 input-focus-glow transition-all dark:text-white"
              />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-3">
                Base URL
              </label>
              <input
                type="url"
                value={baseUrl}
                onChange={(e) => setBaseUrl(e.target.value)}
                placeholder="https://api.example.com/v1"
                className="w-full px-4 py-3.5 rounded-2xl bg-surface-dim dark:bg-dark-card text-base outline-none border border-transparent focus:border-primary/30 input-focus-glow transition-all dark:text-white"
              />
            </div>
          </>
        )}
      </div>
    </div>
  );
}
