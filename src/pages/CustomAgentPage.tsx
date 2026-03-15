import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { ChevronLeft, Check } from 'lucide-react';
import type { AgentRole, TeachingStyle, CorrectionMode } from '@/types';
import { ROLE_LABELS } from '@/types';
import { v4 as uuidv4 } from 'uuid';

export default function CustomAgentPage() {
  const navigate = useNavigate();
  const addCustomAgent = useStore((s) => s.addCustomAgent);

  const [name, setName] = useState('');
  const [nameZh, setNameZh] = useState('');
  const [role, setRole] = useState<AgentRole>('friend');
  const [style, setStyle] = useState<TeachingStyle>('casual');
  const [correctionMode, setCorrectionMode] = useState<CorrectionMode>('endOfTurn');
  const [personality, setPersonality] = useState('');
  const [greeting, setGreeting] = useState('');
  const [targetLevel, setTargetLevel] = useState('intermediate');
  const [topics, setTopics] = useState('');

  const handleSave = () => {
    if (!name.trim() || !nameZh.trim()) return;
    addCustomAgent({
      id: `custom_${uuidv4()}`,
      name: name.trim(),
      nameZh: nameZh.trim(),
      avatarUrl: '',
      role,
      style,
      correctionMode,
      personality: personality.trim() || 'A friendly conversation partner.',
      greeting: greeting.trim() || `Hi! I'm ${name}. Let's chat!`,
      targetLevel,
      topics: topics.split(',').map((t) => t.trim()).filter(Boolean),
      isCustom: true,
      isActive: true,
      createdAt: new Date().toISOString(),
    });
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
        <span className="font-semibold flex-1 dark:text-white">创建自定义伙伴</span>
        <button
          onClick={handleSave}
          disabled={!name.trim() || !nameZh.trim()}
          className="w-11 h-11 rounded-xl flex items-center justify-center text-primary disabled:text-gray-300 dark:disabled:text-gray-600 hover:bg-primary/10 transition-colors"
        >
          <Check size={20} strokeWidth={2.5} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-5 py-5 space-y-5">
        <Field label="英文名" value={name} onChange={setName} placeholder="e.g. Alex" />
        <Field label="中文名" value={nameZh} onChange={setNameZh} placeholder="e.g. 亚历克斯" />

        <ChipGroup
          label="角色"
          options={Object.entries(ROLE_LABELS).map(([k, v]) => ({ value: k, label: v }))}
          selected={role}
          onSelect={(v) => setRole(v as AgentRole)}
        />

        <ChipGroup
          label="教学风格"
          options={[
            { value: 'strict', label: '严格' },
            { value: 'encouraging', label: '鼓励' },
            { value: 'casual', label: '随意' },
            { value: 'socratic', label: '引导' },
          ]}
          selected={style}
          onSelect={(v) => setStyle(v as TeachingStyle)}
        />

        <ChipGroup
          label="纠错模式"
          options={[
            { value: 'immediate', label: '即时' },
            { value: 'endOfTurn', label: '回合后' },
            { value: 'onRequest', label: '按需' },
          ]}
          selected={correctionMode}
          onSelect={(v) => setCorrectionMode(v as CorrectionMode)}
        />

        <ChipGroup
          label="级别"
          options={[
            { value: 'beginner', label: '初级' },
            { value: 'intermediate', label: '中级' },
            { value: 'advanced', label: '高级' },
            { value: 'all', label: '全部' },
          ]}
          selected={targetLevel}
          onSelect={setTargetLevel}
        />

        <Field label="性格描述" value={personality} onChange={setPersonality} placeholder="Describe personality..." multiline />
        <Field label="问候语" value={greeting} onChange={setGreeting} placeholder="Hi! Let's chat!" multiline />
        <Field label="话题 (逗号分隔)" value={topics} onChange={setTopics} placeholder="travel, food, movies" />
      </div>
    </div>
  );
}

function Field({ label, value, onChange, placeholder, multiline }: {
  label: string; value: string; onChange: (v: string) => void; placeholder: string; multiline?: boolean;
}) {
  const cls = "w-full px-4 py-3.5 rounded-2xl bg-surface-dim dark:bg-dark-card text-base outline-none border border-transparent focus:border-primary/30 input-focus-glow transition-all dark:text-white placeholder:text-gray-400";
  return (
    <div>
      <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-2">
        {label}
      </label>
      {multiline ? (
        <textarea value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} rows={3} className={`${cls} resize-none`} />
      ) : (
        <input type="text" value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className={cls} />
      )}
    </div>
  );
}

function ChipGroup({ label, options, selected, onSelect }: {
  label: string;
  options: { value: string; label: string }[];
  selected: string;
  onSelect: (v: string) => void;
}) {
  return (
    <div>
      <label className="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider block mb-2">
        {label}
      </label>
      <div className="flex flex-wrap gap-2">
        {options.map((o) => (
          <button
            key={o.value}
            onClick={() => onSelect(o.value)}
            className={`px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${
              selected === o.value
                ? 'bg-primary text-white shadow-sm shadow-primary/20'
                : 'bg-surface-dim dark:bg-dark-card text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-dark-card'
            }`}
          >
            {o.label}
          </button>
        ))}
      </div>
    </div>
  );
}
