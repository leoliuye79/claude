import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { ChevronLeft, Check } from 'lucide-react';
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
    <div className="flex-1 flex flex-col">
      <header className="flex items-center gap-2 px-2 py-2.5 border-b border-gray-100">
        <button onClick={() => navigate(-1)} className="p-1 text-gray-600">
          <ChevronLeft size={24} />
        </button>
        <span className="font-medium flex-1">AI 模型设置</span>
        <button onClick={handleSave} className="p-2 text-primary">
          <Check size={20} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-5">
        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">提供商</label>
          <div className="space-y-2">
            {PROVIDERS.map((p) => (
              <button
                key={p.id}
                onClick={() => { setProvider(p.id); if (p.models.length) setModel(p.models[0]); }}
                className={`w-full text-left px-4 py-3 rounded-xl border transition-colors ${
                  provider === p.id ? 'border-primary bg-primary/5' : 'border-gray-200'
                }`}
              >
                <span className="text-[15px]">{p.label}</span>
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">API Key</label>
          <input
            type="password"
            value={apiKey}
            onChange={(e) => setApiKey(e.target.value)}
            placeholder={provider === 'claude' ? 'sk-ant-...' : 'sk-...'}
            className="w-full px-4 py-3 rounded-xl border border-gray-200 text-[15px] outline-none focus:border-primary transition-colors"
          />
        </div>

        {currentProvider.models.length > 0 && (
          <div>
            <label className="text-sm font-medium text-gray-500 block mb-2">模型</label>
            <div className="space-y-2">
              {currentProvider.models.map((m) => (
                <button
                  key={m}
                  onClick={() => setModel(m)}
                  className={`w-full text-left px-4 py-3 rounded-xl border transition-colors ${
                    model === m ? 'border-primary bg-primary/5' : 'border-gray-200'
                  }`}
                >
                  <span className="text-sm font-mono">{m}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {provider === 'custom' && (
          <>
            <div>
              <label className="text-sm font-medium text-gray-500 block mb-2">模型名称</label>
              <input
                type="text"
                value={model}
                onChange={(e) => setModel(e.target.value)}
                placeholder="model-name"
                className="w-full px-4 py-3 rounded-xl border border-gray-200 text-[15px] outline-none focus:border-primary transition-colors"
              />
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500 block mb-2">Base URL</label>
              <input
                type="url"
                value={baseUrl}
                onChange={(e) => setBaseUrl(e.target.value)}
                placeholder="https://api.example.com/v1"
                className="w-full px-4 py-3 rounded-xl border border-gray-200 text-[15px] outline-none focus:border-primary transition-colors"
              />
            </div>
          </>
        )}
      </div>
    </div>
  );
}
