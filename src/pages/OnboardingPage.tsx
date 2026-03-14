import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useStore } from '@/store';
import { MessageCircle, BookOpen, Mic, ArrowRight, Sparkles } from 'lucide-react';

const STEPS = [
  {
    icon: MessageCircle,
    title: '与 AI 伙伴对话',
    subtitle: '6 位风格各异的英语伙伴，随时随地陪你练习口语',
    gradient: 'from-blue-500 to-cyan-400',
    bg: 'bg-blue-50 dark:bg-blue-950/30',
  },
  {
    icon: BookOpen,
    title: '智能纠错反馈',
    subtitle: 'AI 实时纠正语法错误，附带中英文详细解释',
    gradient: 'from-violet-500 to-purple-400',
    bg: 'bg-violet-50 dark:bg-violet-950/30',
  },
  {
    icon: Mic,
    title: '沉浸式学习',
    subtitle: '语音输入、TTS 朗读，打造真实语言环境',
    gradient: 'from-rose-500 to-orange-400',
    bg: 'bg-rose-50 dark:bg-rose-950/30',
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
    <div className="flex-1 flex flex-col bg-white dark:bg-gray-900">
      {/* Top decoration */}
      <div className="h-2 gradient-primary" />

      {/* Skip button */}
      {step < STEPS.length - 1 && (
        <div className="flex justify-end px-5 pt-4">
          <button
            onClick={() => { completeOnboarding(); navigate('/', { replace: true }); }}
            className="text-gray-400 dark:text-gray-500 text-sm font-medium px-3 py-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            跳过
          </button>
        </div>
      )}

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-10 animate-fade-in" key={step}>
        {/* Icon with gradient ring */}
        <div className={`relative mb-10`}>
          <div className={`w-28 h-28 rounded-3xl bg-gradient-to-br ${s.gradient} flex items-center justify-center shadow-lg`}>
            <Icon size={48} className="text-white" strokeWidth={1.5} />
          </div>
          <div className={`absolute -right-2 -top-2 w-8 h-8 rounded-full bg-gradient-to-br ${s.gradient} opacity-30 blur-sm`} />
          <div className={`absolute -left-3 -bottom-3 w-10 h-10 rounded-full bg-gradient-to-br ${s.gradient} opacity-20 blur-md`} />
        </div>

        <h1 className="text-[26px] font-bold tracking-tight mb-3 dark:text-white">{s.title}</h1>
        <p className="text-gray-500 dark:text-gray-400 text-center text-[15px] leading-relaxed mb-4 max-w-[280px]">
          {s.subtitle}
        </p>
      </div>

      {/* Bottom section */}
      <div className="px-8 pb-12">
        {/* Progress dots */}
        <div className="flex justify-center gap-2 mb-8">
          {STEPS.map((_, i) => (
            <div
              key={i}
              className={`h-1.5 rounded-full transition-all duration-300 ${
                i === step ? 'w-8 bg-primary' : i < step ? 'w-1.5 bg-primary/40' : 'w-1.5 bg-gray-200 dark:bg-gray-700'
              }`}
            />
          ))}
        </div>

        <button
          onClick={handleNext}
          className="w-full gradient-primary text-white py-4 rounded-2xl font-semibold flex items-center justify-center gap-2 shadow-lg shadow-primary/25 active:scale-[0.98] transition-transform"
        >
          {step < STEPS.length - 1 ? (
            <>下一步 <ArrowRight size={18} /></>
          ) : (
            <><Sparkles size={18} /> 开始使用</>
          )}
        </button>
      </div>
    </div>
  );
}
