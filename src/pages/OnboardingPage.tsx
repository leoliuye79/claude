import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { MessageCircle, BookOpen, Mic, ChevronRight } from 'lucide-react';

const STEPS = [
  {
    icon: MessageCircle,
    title: '与 AI 伙伴对话',
    subtitle: '6 位风格各异的英语伙伴随时陪你练习',
    color: 'text-blue-500 bg-blue-50',
  },
  {
    icon: BookOpen,
    title: '智能纠错反馈',
    subtitle: 'AI 实时纠正语法错误，附带中英文解释',
    color: 'text-green-500 bg-green-50',
  },
  {
    icon: Mic,
    title: '沉浸式学习',
    subtitle: '语音输入、TTS 朗读，打造真实语言环境',
    color: 'text-purple-500 bg-purple-50',
  },
];

export default function OnboardingPage() {
  const [step, setStep] = useState(0);
  const navigate = useNavigate();
  const completeOnboarding = useStore((s) => s.completeOnboarding);

  const handleNext = () => {
    if (step < STEPS.length - 1) {
      setStep(step + 1);
    } else {
      completeOnboarding();
      navigate('/', { replace: true });
    }
  };

  const s = STEPS[step];
  const Icon = s.icon;

  return (
    <div className="flex-1 flex flex-col items-center justify-center px-8">
      <div className={`w-24 h-24 rounded-full ${s.color} flex items-center justify-center mb-8`}>
        <Icon size={40} />
      </div>
      <h1 className="text-2xl font-bold mb-3">{s.title}</h1>
      <p className="text-gray-500 text-center mb-12">{s.subtitle}</p>

      <div className="flex gap-2 mb-8">
        {STEPS.map((_, i) => (
          <div key={i} className={`w-2 h-2 rounded-full ${i === step ? 'bg-primary w-6' : 'bg-gray-200'} transition-all`} />
        ))}
      </div>

      <button
        onClick={handleNext}
        className="w-full max-w-xs bg-primary text-white py-3 rounded-full font-medium flex items-center justify-center gap-2 hover:bg-primary-dark transition-colors"
      >
        {step < STEPS.length - 1 ? '下一步' : '开始使用'}
        <ChevronRight size={18} />
      </button>

      {step < STEPS.length - 1 && (
        <button
          onClick={() => { completeOnboarding(); navigate('/', { replace: true }); }}
          className="mt-4 text-gray-400 text-sm"
        >
          跳过
        </button>
      )}
    </div>
  );
}
