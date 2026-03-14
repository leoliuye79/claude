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
    <div className="flex-1 flex flex-col">
      <header className="flex items-center gap-2 px-2 py-2.5 border-b border-gray-100">
        <button onClick={() => navigate(-1)} className="p-1 text-gray-600">
          <ChevronLeft size={24} />
        </button>
        <span className="font-medium flex-1">创建自定义伙伴</span>
        <button onClick={handleSave} disabled={!name.trim() || !nameZh.trim()} className="p-2 text-primary disabled:text-gray-300">
          <Check size={20} />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        <Field label="英文名" value={name} onChange={setName} placeholder="e.g. Alex" />
        <Field label="中文名" value={nameZh} onChange={setNameZh} placeholder="e.g. 亚历克斯" />

        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">角色</label>
          <div className="flex flex-wrap gap-2">
            {(Object.keys(ROLE_LABELS) as AgentRole[]).map((r) => (
              <button key={r} onClick={() => setRole(r)}
                className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${role === r ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200'}`}>
                {ROLE_LABELS[r]}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">教学风格</label>
          <div className="flex flex-wrap gap-2">
            {(['strict', 'encouraging', 'casual', 'socratic'] as TeachingStyle[]).map((s) => (
              <button key={s} onClick={() => setStyle(s)}
                className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${style === s ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200'}`}>
                {s}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">纠错模式</label>
          <div className="flex flex-wrap gap-2">
            {(['immediate', 'endOfTurn', 'onRequest'] as CorrectionMode[]).map((c) => (
              <button key={c} onClick={() => setCorrectionMode(c)}
                className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${correctionMode === c ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200'}`}>
                {c}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="text-sm font-medium text-gray-500 block mb-2">级别</label>
          <div className="flex flex-wrap gap-2">
            {['beginner', 'intermediate', 'advanced', 'all'].map((l) => (
              <button key={l} onClick={() => setTargetLevel(l)}
                className={`px-3 py-1.5 rounded-full text-sm border transition-colors ${targetLevel === l ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200'}`}>
                {l}
              </button>
            ))}
          </div>
        </div>

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
  const cls = "w-full px-4 py-3 rounded-xl border border-gray-200 text-[15px] outline-none focus:border-primary transition-colors";
  return (
    <div>
      <label className="text-sm font-medium text-gray-500 block mb-2">{label}</label>
      {multiline ? (
        <textarea value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} rows={3} className={`${cls} resize-none`} />
      ) : (
        <input type="text" value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder} className={cls} />
      )}
    </div>
  );
}
